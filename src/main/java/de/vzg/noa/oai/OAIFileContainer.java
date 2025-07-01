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
import java.io.UncheckedIOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.mycore.oai.pmh.Record;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class OAIFileContainer {

    private static final Logger LOGGER = LogManager.getLogger();

    private List<OAIFile> files;

    private URL url;

    public static OAIFileContainer parse(Record record) throws MalformedURLException {
        OAIFileContainer cont = null;
        Element metadata = record.getMetadata().toXML();

        Namespace ns = Namespace.getNamespace("http://www.d-nb.de/standards/ddb/");

        Optional<List<OAIFile>> files = Optional.ofNullable(metadata
            .getChildren("fileProperties", ns)).filter(c -> !c.isEmpty()).map(c -> c.stream().map(fp -> {
                OAIFile file = new OAIFile();
                file.setName(fp.getAttributeValue("fileName", ns));
                file.setSize(Long.parseLong(fp.getAttributeValue("fileSize", ns)));
                return file;
            }).collect(Collectors.toList()));

        Optional<URL> transferURL = Optional.ofNullable(metadata.getChildText("transfer", ns)).map(t -> {
            try {
                return new URL(t);
            } catch (MalformedURLException e) {
                LOGGER.warn(e.getMessage(), e);
                return null;
            }
        }).filter(u -> u != null);

        if (files.isPresent() || transferURL.isPresent()) {
            cont = new OAIFileContainer();
            files.ifPresent(cont::setFiles);
            transferURL.ifPresent(cont::setUrl);
        }

        return cont;
    }

    private void saveFile(Path tmpFile, Path outputDir, OAIFile f) throws IOException {
        Path out = outputDir.resolve(f.getName());
        LOGGER.info("Save file {}", out);
        Files.copy(tmpFile, out, StandardCopyOption.REPLACE_EXISTING);
        long fs = Files.size(out);
        if (f.getSize() != fs) {
            LOGGER.warn("File size differs should be {} but is {}.", f.getSize(), fs);
        }
    }

    private void checkExtractedFiles(List<Path> extractedFiles) {
        Map<Path, OAIFile> foundFiles = extractedFiles.stream()
            .collect(Collectors.toMap(ef -> ef, ef -> files.stream()
                .filter(f -> f.getName().equalsIgnoreCase(ef.getFileName().toString())).findFirst()
                .orElse(null)));
        foundFiles.forEach((ef, of) -> {
            LOGGER.info("Check file {}", ef);
            try {
                if (of != null) {
                    long fs = Files.size(ef);
                    if (of.getSize() != fs) {
                        LOGGER.warn("File size differs should be {} but is {}.", of.getSize(), fs);
                    }
                } else {
                    LOGGER.warn("File was extracted but not specified within fileset.");
                }
            } catch (IOException e) {
                throw new UncheckedIOException(e);
            }
        });
    }

    /**
     * @return the files
     */
    public List<OAIFile> getFiles() {
        return files;
    }

    /**
     * @param files the files to set
     */
    public void setFiles(List<OAIFile> files) {
        this.files = files;
    }

    /**
     * @return the url
     */
    public URL getUrl() {
        return url;
    }

    /**
     * @param url the url to set
     */
    public void setUrl(URL url) {
        this.url = url;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        final int maxLen = 10;
        StringBuilder builder = new StringBuilder();
        builder.append("OAIFileContainer [");
        if (files != null) {
            builder.append("files=");
            builder.append(files.subList(0, Math.min(files.size(), maxLen)));
            builder.append(", ");
        }
        if (url != null) {
            builder.append("url=");
            builder.append(url);
        }
        builder.append("]");
        return builder.toString();
    }

}
