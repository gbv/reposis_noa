package de.vzg.noa;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Stream;

import javax.servlet.ServletContext;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.common.SolrDocument;
import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessInterface;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.common.MCRPersistenceException;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.common.events.MCRShutdownHandler;
import org.mycore.common.events.MCRStartupHandler;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetaIFS;
import org.mycore.datamodel.metadata.MCRMetaLinkID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.metadata.MCRObjectStructure;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.mods.MCRMODSSorter;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.oai.pmh.Header;
import org.mycore.oai.pmh.harvester.HarvesterBuilder;
import org.mycore.oai.pmh.harvester.HarvesterUtil;
import org.mycore.solr.MCRSolrClientFactory;
import org.mycore.solr.search.MCRSolrSearchUtils;
import org.mycore.util.concurrent.MCRFixedUserCallable;

import de.vzg.noa.oai.OAIRecord;
import de.vzg.noa.oai.RecordTransformer;

public class OAIUpdateCron implements MCRStartupHandler.AutoExecutable, Runnable {

    public static final String OAILAST_HARVEST_TXT = "OAILastHarvest.txt";

    public static final int HARVEST_DELAY = 1000 * 60 * 60 * 3;

    public static final MCRConfiguration CONFIG = MCRConfiguration.instance();

    private static final Logger LOGGER = LogManager.getLogger();

    private static final Date EARLY_DATE = new Date(1);

    private static HashMap<String, MCRObjectID> existingIssnMap = new HashMap<>();

    private static HashMap<String, MCRObjectID> existingOAIIDMap = new HashMap<>();

    private ScheduledExecutorService cronExecutorService;

    private static void addShutdownHandler(ExecutorService executorService) {
        MCRShutdownHandler.getInstance().addCloseable(() -> {
            executorService.shutdown();
            try {
                executorService.awaitTermination(10, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                LOGGER.error("Interupted wait for termination.", e);
            }
        });
    }

    private static MCRDerivate createDerivate(MCRObjectID documentID, String mainFile)
        throws MCRPersistenceException, IOException, MCRAccessException {
        MCRDerivate derivate = new MCRDerivate();
        derivate.setId(MCRObjectID.getNextFreeId(documentID.getProjectId(), "derivate"));
        derivate.setLabel("data object from " + documentID);

        String schema = MCRConfiguration.instance().getString("MCR.Metadata.Config.derivate", "datamodel-derivate.xml")
            .replaceAll(".xml",
                ".xsd");
        derivate.setSchema(schema);

        MCRMetaLinkID linkId = new MCRMetaLinkID();
        linkId.setSubTag("linkmeta");
        linkId.setReference(documentID, null, null);
        derivate.getDerivate().setLinkMeta(linkId);

        MCRMetaIFS ifs = new MCRMetaIFS();
        ifs.setSubTag("internal");
        ifs.setSourcePath(null);
        ifs.setMainDoc(mainFile);
        derivate.getDerivate().setInternals(ifs);

        LOGGER.debug("Creating new derivate with ID {}", derivate.getId());
        MCRMetadataManager.create(derivate);

        setDefaultPermissions(derivate.getId());

        return derivate;
    }

    protected static void setDefaultPermissions(MCRObjectID derivateID) {
        if (MCRConfiguration.instance().getBoolean("MCR.Access.AddDerivateDefaultRule", true)) {
            MCRAccessInterface ai = MCRAccessManager.getAccessImpl();
            Collection<String> configuredPermissions = ai.getAccessPermissionsFromConfiguration();
            for (String permission : configuredPermissions) {
                MCRAccessManager.addRule(derivateID, permission, MCRAccessManager.getTrueRule(),
                    "default derivate rule");
            }
        }
    }

    private Date getLastHarvestDate() {
        final Path lastHarvestFile = getLastHarvestDateFilePath();

        if (Files.exists(lastHarvestFile)) {
            try {
                return Files.readAllLines(lastHarvestFile).stream().findFirst().map(str -> {
                    try {
                        return new SimpleDateFormat(
                            RecordTransformer.OAI_SIMPLE_FORMAT).parse(str);
                    } catch (ParseException e) {
                        LOGGER.error("Error while parsing date " + str, e);
                        return null;
                    }
                }).orElse(EARLY_DATE);
            } catch (IOException e) {
                LOGGER.error("Error while reading date of last harvest from " + lastHarvestFile.toString(), e);

            }
        } else {
            LOGGER.info("{} not found. Assume last harvest was {}", OAILAST_HARVEST_TXT, EARLY_DATE.toString());
        }
        return EARLY_DATE;
    }

    private Path getLastHarvestDateFilePath() {
        final Path configPath = MCRConfigurationDir.getConfigurationDirectory().toPath();
        return configPath.resolve(OAILAST_HARVEST_TXT);
    }

    private void saveLastHarvestDate(Date lastHarvest) {
        final Path lastHarvestDateFilePath = getLastHarvestDateFilePath();
        final String dateAsString = new SimpleDateFormat(RecordTransformer.OAI_SIMPLE_FORMAT).format(lastHarvest);
        try {
            Files.write(lastHarvestDateFilePath, dateAsString.getBytes(StandardCharsets.UTF_8),
                StandardOpenOption.CREATE);
        } catch (IOException e) {
            LOGGER.error("Error while writing lastHarvestDate", e);
        }
    }


    public static void main(String[] args) {
        final RecordTransformer recordTransformer = new RecordTransformer("http://oai-pmh.copernicus.org/", "mods", "copernicus");
        final Stream<Header> headerStream = HarvesterUtil
            .streamHeaders(HarvesterBuilder.createNewInstance("http://oai-pmh.copernicus.org/"), "mods", null, null,
                "copernicus");

        headerStream.forEach(hs->{
            if(hs.getId().equals("oai:publications.copernicus.org:angeo33803")){
                System.out.println("Found it!");
            }
        });
    }

    private MCRObject mapToObject(OAIRecord oaiRecord) {
        // add identifier type importID to document
        final Element modsRoot = oaiRecord.getDocument().getRootElement();
        final String oaiId = oaiRecord.getRecord().getHeader().getId();
        SolrDocument first = null;
        try {
            first = MCRSolrSearchUtils
                .first(MCRSolrClientFactory.getMainSolrClient(), "mods.identifier:\"" + oaiId + "\"");
        } catch (SolrServerException | IOException e) {
        }
        final MCRObject cop;
        if (first == null) {
            cop = MCRMODSWrapper.wrapMODSDocument(modsRoot, CONFIG.getString("OAI.Harvest.ProjectID"));
            cop.setId(nextFreeID());
        } else {
            final String id = (String) first.getFieldValue("id");
            LOGGER.info("Found object to update: " + id);
            final MCRObjectID objectID = MCRObjectID.getInstance(id);
            cop = MCRMetadataManager.retrieveMCRObject(objectID);
            new MCRMODSWrapper(cop).setMODS(modsRoot);
        }

        final Element identifierElement = new Element("identifier", MCRConstants.MODS_NAMESPACE);
        identifierElement.setAttribute("type", "importID");
        identifierElement.setText(oaiId);
        final MCRMODSWrapper wrapper = new MCRMODSWrapper(cop);
        wrapper.addElement(identifierElement);

        MCRMODSSorter.sort(wrapper.getMODS());

        return cop;
    }

    private boolean checkRecordExists(OAIRecord oaiRecord) {
        // check if already exist
        final String recordID = oaiRecord.getRecord().getHeader().getId();
        if (existingOAIIDMap.containsKey(recordID)) {
            LOGGER.info("Object for OAI Record {} already exists!", oaiRecord.getRecord().getHeader().getId());
            return false;
        }
        try {
            final SolrDocument first = MCRSolrSearchUtils
                .first(MCRSolrClientFactory.getMainSolrClient(), "mods.identifier:\"" + recordID + "\"");
            if (first != null) {
                LOGGER.info("Object for OAI Record {} already exists!", oaiRecord.getRecord().getHeader().getId());
                final String id = (String) first.getFirstValue("id");
                existingOAIIDMap.put(recordID, MCRObjectID.getInstance(id));
                return false;
            } else {
                return true;
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private MCRObjectID nextFreeID() {
        return MCRObjectID.getNextFreeId("cop", "mods");
    }

    private boolean isHost(Element relatedItem) {
        return "host".equals(relatedItem.getAttributeValue("type"));
    }

    private MCRObjectID createRelatedObject(Element relatedItem, MCRObjectID childID)
        throws MCRPersistenceException, MCRAccessException {
        MCRMODSWrapper wrapper = new MCRMODSWrapper();
        MCRObject object = wrapper.getMCRObject();
        MCRObjectID oid = MCRObjectID.getNextFreeId(childID.getBase());
        if (oid.equals(childID)) {
            oid = MCRObjectID.getNextFreeId(childID.getBase());
        }
        object.setId(oid);

        if (isHost(relatedItem)) {
            object.getStructure().addChild(new MCRMetaLinkID("child", childID, childID.toString(), childID.toString()));
        }

        Element mods = cloneRelatedItem(relatedItem);
        wrapper.setMODS(mods);

        LOGGER.info("create object {}", oid);
        setState(object);
        MCRMODSSorter.sort(wrapper.getMODS());
        MCRMetadataManager.create(object);
        return oid;
    }

    private Element cloneRelatedItem(Element relatedItem) {
        Element mods = relatedItem.clone();
        mods.setName("mods");
        mods.removeAttribute("type");
        mods.removeAttribute("href", MCRConstants.XLINK_NAMESPACE);
        mods.removeAttribute("type", MCRConstants.XLINK_NAMESPACE);
        mods.removeChildren("part", MCRConstants.MODS_NAMESPACE);
        return mods;
    }

    @Override
    public String getName() {
        return getClass().getName();
    }

    @Override
    public int getPriority() {
        return 0;
    }

    @Override
    public void startUp(ServletContext servletContext) {
        LOGGER.info("Starting " + getClass().getName());
        cronExecutorService = Executors
            .newScheduledThreadPool(1, r -> new Thread(r, getClass().getSimpleName() + ".cron"));
        addShutdownHandler(cronExecutorService);
        cronExecutorService.scheduleWithFixedDelay(this, 1, 60 * 24, TimeUnit.MINUTES);
    }

    @Override
    public void run() {
        try {
            Date lastHarvest = getLastHarvestDate();

            final Date newHarvest = new Date();
            if (new Date(lastHarvest.getTime() + HARVEST_DELAY).before(newHarvest)) {
                LOGGER.info("Start Harvesting!");
                final RecordTransformer recordTransformer = new RecordTransformer(
                    CONFIG.getString("OAI.Harvest.Host"),
                    CONFIG.getString("OAI.Harvest.Format"),
                    CONFIG.getString("OAI.Harvest.Set"));

                recordTransformer.transformAll(CONFIG.getString("OAI.Harvest.Stylesheet"), lastHarvest, null)
                    .map(this::mapToObject)
                    .map(this::getCreateOrUpdateCallable)
                    .forEach(createOrUpdateCallable -> {
                        try {
                            createOrUpdateCallable.call();
                        } catch (Exception e) {
                            throw new MCRException("Error while creating object!", e);
                        }
                    });

                saveLastHarvestDate(newHarvest);
            }
        } catch (Throwable t) {
            LOGGER.error("Error ", t);
        }
    }

    private MCRFixedUserCallable<Void> getCreateOrUpdateCallable(MCRObject object) {
        return new MCRFixedUserCallable<>(() -> {
            final MCRMODSWrapper mw = new MCRMODSWrapper(object);
            // assign right parent
            mw.getElements("mods:relatedItem")
                .forEach(relatedItemElement -> {
                    final XPathExpression<Element> xpath = XPathFactory.instance()
                        .compile("mods:identifier[@type='issn']", Filters.element(), null,
                            MCRConstants.MODS_NAMESPACE);
                    final Element issnElement = xpath.evaluateFirst(relatedItemElement);
                    final String issn = issnElement.getTextTrim();
                    if (existingIssnMap.containsKey(issn)) {
                        LOGGER.info("Object for issn {} already exists!", issn);
                        final MCRObjectID mcrObjectID = existingIssnMap.get(issn);
                        relatedItemElement
                            .setAttribute("href", mcrObjectID.toString(), MCRConstants.XLINK_NAMESPACE);
                    } else {
                        try {
                            final SolrDocument first = MCRSolrSearchUtils
                                .first(MCRSolrClientFactory.getMainSolrClient(), "mods.identifier:\"" + issn + "\"");
                            if (first == null) {
                                LOGGER.info("Create parent Object for issn {} !", issn);
                                // create object
                                final MCRObjectID objectID = createRelatedObject(relatedItemElement,
                                    object.getId());
                                relatedItemElement.setAttribute("href", objectID.toString(),
                                    MCRConstants.XLINK_NAMESPACE);
                                existingIssnMap.put(issn, objectID);
                            } else {
                                LOGGER.info("Object for issn {} already exists!", issn);
                                final String id = (String) first.getFieldValue("id");
                                final MCRObjectID objectID = MCRObjectID.getInstance(id);
                                relatedItemElement.setAttribute("href", id, MCRConstants.XLINK_NAMESPACE);
                                existingIssnMap.put(issn, objectID);
                            }
                        } catch (Exception e) {
                            throw new RuntimeException("Error checking for exist: " + issn, e);
                        }
                    }
                });

            // save object
            try {
                setState(object);
                LOGGER.info("Create child object {}!", object.getId().toString());
                final Optional<MCRObjectID> alreadyExists = Optional.of(object.getId())
                    .filter(MCRMetadataManager::exists);

                final boolean hasDerivate = alreadyExists
                    .map(MCRMetadataManager::retrieveMCRObject)
                    .map(MCRObject::getStructure)
                    .map(MCRObjectStructure::getDerivates)
                    .map(List::size)
                    .filter(s -> s > 0)
                    .isPresent();

                AtomicBoolean hasFiles = new AtomicBoolean(hasDerivate);
                if (!alreadyExists.isPresent()) {
                    MCRMetadataManager.create(object);

                    // create files
                    final Optional<URL> urlOpt = Optional
                        .ofNullable(mw.getElement("mods:location/mods:url[@access='raw object']"))
                        .map(Element::getTextTrim)
                        .map(s -> {
                            try {
                                return new URL(s);
                            } catch (MalformedURLException e) {
                                return null;
                            }
                        });
                    if (urlOpt.isPresent()) {
                        try (InputStream is = urlOpt.get().openStream()) {
                            // detect the file name
                            final String[] parts = urlOpt.get().getPath().split("/");
                            final String fileName = parts[parts.length - 1];

                            // we can open the stream, so we can create the derivate!
                            final MCRDerivate derivate = createDerivate(object.getId(), fileName);
                            final MCRPath dest = MCRPath.getPath(derivate.getId().toString(), "/" + fileName);
                            Files.copy(is, dest);
                            hasFiles.set(true);
                        } catch (IOException | MCRAccessException e) {
                            LOGGER.error("Error while downloading file!", e);
                        }
                    }
                }

                if (!hasFiles.get()) {
                    final Element note = new Element("note", MCRConstants.MODS_NAMESPACE);
                    note.setAttribute("type", "content");
                    note.setText(CONFIG.getString("OAI.Harvest.NoFileMessage"));
                    mw.addElement(note);
                }

                MCRMetadataManager.update(object);
            } catch (MCRAccessException e) {
                throw new MCRException("Error while creating " + object.getId().toString(), e);
            }
            return null;
        }, MCRSystemUserInformation.getJanitorInstance());
    }

    private void setState(MCRObject object) {
        object.getService().setState(MCRCategoryID.fromString("state:" + CONFIG.getString("OAI.Harvest.DocStatus")));
    }
}
