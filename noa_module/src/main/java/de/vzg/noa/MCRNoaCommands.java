package de.vzg.noa;

import java.io.IOException;
import java.net.URL;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mods.MCRMODSWrapper;

@MCRCommandGroup(name = "NoaCommands")
public class MCRNoaCommands {


    @MCRCommand(syntax = "Fix file for object {0}")
    public static void fixFileOfObject(String objectIdString) throws IOException {
        final MCRObjectID objectID = MCRObjectID.getInstance(objectIdString);
        final List<MCRObjectID> derivateIds = MCRMetadataManager.getDerivateIds(objectID, 1, TimeUnit.MINUTES);

        final MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);

        final MCRMODSWrapper wrapper = new MCRMODSWrapper(object);
        final String url = wrapper.getElement("mods:location/mods:url[@access='raw object']").getText();
        final Optional<MCRObjectID> derivateIDOptional = derivateIds.stream().findFirst();

        if(derivateIDOptional.isPresent()){
            final MCRObjectID derivateID = derivateIDOptional.get();

            OAIUpdateCron.downloadFile(object, new AtomicBoolean(), new URL(url),(o, main)-> {
                return MCRMetadataManager.retrieveMCRDerivate(derivateID);
            });
        }
    }
}
