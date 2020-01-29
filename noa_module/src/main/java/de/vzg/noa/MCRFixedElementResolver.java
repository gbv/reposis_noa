package de.vzg.noa;

import java.net.MalformedURLException;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import org.jdom2.Element;
import org.jdom2.transform.JDOMSource;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.common.MCRLanguageDetector;
import org.mycore.datamodel.common.MCRDataURL;

public class MCRFixedElementResolver implements URIResolver {

    public static final String XML_PREFIX = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        final String[] split = href.split(":", 3);
        final String element = split[1];
        final String base64HTML = split[2];
        final String repGroup = UUID.randomUUID().toString().substring(16, 32).replace("-", "");

        try {
            final MCRDataURL url = MCRDataURL.parse(base64HTML);
            final byte[] data = url.getData();
            final String htmlString = new String(data, url.getCharset());

            final Document jsoup = Jsoup.parse(htmlString);
            jsoup.outputSettings().syntax(Document.OutputSettings.Syntax.xml);

            final String cleanText = jsoup.text();
            final String cleanXML = jsoup.body().html();

            final String lang = MCRLanguageDetector.detectLanguage(cleanText);

            final String resultURL;
            if (element.equals("titleInfo")) {
                final String content =
                    XML_PREFIX + "<titleInfo xml:lang=\"" + lang + "\"><title>" + cleanXML + "</title></titleInfo>";
                resultURL = MCRDataURL.build(content, "base64", "text/xml", "UTF-8");
                final Element titleInfoElement = new Element("titleInfo", MCRConstants.MODS_NAMESPACE);
                titleInfoElement.setAttribute("altRepGroup", repGroup);
                titleInfoElement.setAttribute("type", "simple", MCRConstants.XLINK_NAMESPACE);
                titleInfoElement.setAttribute("lang", lang, MCRConstants.XML_NAMESPACE);

                final Element htmlTitleInfoElement = titleInfoElement.clone();
                htmlTitleInfoElement.setAttribute("altFormat", resultURL);
                htmlTitleInfoElement.setAttribute("contentType", "text/xml");

                final Element title = new Element("title", MCRConstants.MODS_NAMESPACE);
                title.setText(cleanText);
                titleInfoElement.addContent(title);

                return new JDOMSource(Stream.of(titleInfoElement, htmlTitleInfoElement).collect(Collectors.toList()));
            } else if (element.equals("abstract")) {
                final String content = XML_PREFIX + "<abstract xml:lang=\"" + lang + "\">" + cleanXML + "</abstract>";
                resultURL = MCRDataURL.build(content, "base64", "text/xml", "UTF-8");
                final Element abstractElement = new Element("abstract", MCRConstants.MODS_NAMESPACE);
                abstractElement.setAttribute("altRepGroup", repGroup);
                abstractElement.setAttribute("type", "simple", MCRConstants.XLINK_NAMESPACE);
                abstractElement.setAttribute("lang", lang, MCRConstants.XML_NAMESPACE);

                final Element htmlAbstractElement = abstractElement.clone();
                htmlAbstractElement.setAttribute("altFormat", resultURL);
                htmlAbstractElement.setAttribute("contentType", "text/xml");

                abstractElement.setText(cleanText);
                return new JDOMSource(Stream.of(abstractElement, htmlAbstractElement).collect(Collectors.toList()));
            } else {
                throw new MCRException("Unknown element: " + element);
            }

        } catch (MalformedURLException e) {
            throw new MCRException("Error while parsing DataURL", e);
        }
    }

}
