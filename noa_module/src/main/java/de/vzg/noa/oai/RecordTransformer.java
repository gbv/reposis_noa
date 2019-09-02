/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */
package de.vzg.noa.oai;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Stream;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamSource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.jdom2.transform.JDOMResult;
import org.jdom2.transform.JDOMSource;
import org.mycore.common.MCRClassTools;
import org.mycore.oai.pmh.CannotDisseminateFormatException;
import org.mycore.oai.pmh.Header;
import org.mycore.oai.pmh.IdDoesNotExistException;
import org.mycore.oai.pmh.Record;
import org.mycore.oai.pmh.harvester.HarvestException;
import org.mycore.oai.pmh.harvester.Harvester;
import org.mycore.oai.pmh.harvester.HarvesterBuilder;
import org.mycore.oai.pmh.harvester.HarvesterUtil;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class RecordTransformer {

    public static final String OAI_SIMPLE_FORMAT = "yyyy-MM-dd";

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String DEFAULT_FORMAT = "oai_dc";

    private static TransformerFactory factory = TransformerFactory
        .newInstance("net.sf.saxon.TransformerFactoryImpl", MCRClassTools
            .getClassLoader());

    private final String baseURL;

    private String format;

    private String setSpec;

    private Harvester harvester;

    private Function<String, String> formatFunc = (format) -> {
        if (format == null || !harvester.listMetadataFormats().stream().anyMatch(mf -> mf.getPrefix().equals(format))) {
            LOGGER.warn("Metadata format \"{}\" isn't supported fallback to default format (\"{}\").", format,
                DEFAULT_FORMAT);
            return DEFAULT_FORMAT;
        } else {
            return format;
        }
    };

    public RecordTransformer(String baseURL) {
        this(baseURL, null);
    }

    public RecordTransformer(String baseURL, String format) {
        this(baseURL, format, null);
    }

    public RecordTransformer(String baseURL, String format, String setSpec) {
        this(baseURL, format, setSpec, true);
    }

    public RecordTransformer(String baseURL, String format, String setSpec, boolean skipFormatCheck) {
        this.baseURL = baseURL;
        this.setSpec = setSpec;
        harvester = HarvesterBuilder.createNewInstance(this.baseURL);
        this.format = !skipFormatCheck ? formatFunc.apply(format) : format;
    }

    public OAIRecord transform(String id) throws CannotDisseminateFormatException, HarvestException,
        IdDoesNotExistException, MalformedURLException {
        return transform(id, null);
    }

    public OAIRecord transform(String id, String stylesheet) throws CannotDisseminateFormatException,
        HarvestException, IdDoesNotExistException {

        Record r = harvester.getRecord(id, format);

        if (r.getMetadata() == null) {
            LOGGER.warn("No metadata found for record with id {}.", id);
            return null;
        }

        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug((new XMLOutputter(Format.getPrettyFormat())).outputString(r.getMetadata().toXML()));
        }

        try {
            Map<String, Object> params = new HashMap<>();
            params.put("recordBaseURL", baseURL);
            params.put("recordId", id);

            JDOMResult result = transform(r.getMetadata().toXML(),
                Optional.ofNullable(stylesheet).orElse("/transformer/" + format + ".xsl"), params);

            OAIRecord record = new OAIRecord(r);
            record.setDocument(result.getDocument());
            record.setContainer(OAIFileContainer.parse(r));

            return record;
        } catch (TransformerException | IOException e) {
            throw new IllegalArgumentException(
                "Couldn't transform metadata with provided xsl stylesheet ("
                    + Optional.ofNullable(stylesheet).orElse("/transformer/" + format + ".xsl") + ").",
                e);
        }
    }

    public Stream<OAIRecord> transformAll() throws HarvestException {
        return transformAll(null);
    }

    public Stream<OAIRecord> transformAll(String stylesheet) throws HarvestException {
        return transformAll(stylesheet, null, null);
    }

    public Stream<OAIRecord> transformAll(String stylesheet, Date from, Date until) {
        final String fromString = from != null ? new SimpleDateFormat(OAI_SIMPLE_FORMAT).format(from) : null;
        final String untilString = until != null ? new SimpleDateFormat(OAI_SIMPLE_FORMAT).format(until) : null;
        return processRecords(HarvesterUtil.streamHeaders(harvester, format, fromString, untilString, setSpec),
            stylesheet);
    }

    private JDOMResult transform(Element xml, String stylesheet, Map<String, Object> params)
        throws TransformerException, IOException {
        InputStream xis = getClass().getResourceAsStream(stylesheet);
        if (xis == null) {
            xis = MCRClassTools
                .getClassLoader().getResourceAsStream("xsl/" + stylesheet);
        }

        Source xslt = new StreamSource(xis);
        Transformer transformer = factory.newTransformer(xslt);
        Optional.ofNullable(params).ifPresent(p -> p.forEach(transformer::setParameter));
        JDOMResult result = new JDOMResult();
        transformer.transform(new JDOMSource(xml), result);

        xis.close();

        return result;
    }

    public Stream<OAIRecord> processRecords(Stream<Header> recordStream, String stylesheet) {
        return recordStream.parallel().map(h -> {
            try {
                return this.transform(h.getId(), stylesheet);
            } catch (Throwable e) {
                LOGGER.error("Error while downloading: " + h.getId(), e);
                return null;
            }
        }).filter(Objects::nonNull);
    }
}
