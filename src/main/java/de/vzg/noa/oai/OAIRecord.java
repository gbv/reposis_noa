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

import org.jdom2.Document;
import org.mycore.oai.pmh.Record;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class OAIRecord {

    private Record record;

    private Document document;

    private OAIFileContainer container;

    /**
     * @param record
     */
    public OAIRecord(Record record) {
        this.record = record;
    }

    /**
     * @return the record
     */
    public Record getRecord() {
        return record;
    }

    /**
     * @param record the record to set
     */
    public void setRecord(Record record) {
        this.record = record;
    }

    /**
     * @return the document
     */
    public Document getDocument() {
        return document;
    }

    /**
     * @param document the document to set
     */
    public void setDocument(Document document) {
        this.document = document;
    }

    /**
     * @return the container
     */
    public OAIFileContainer getContainer() {
        return container;
    }

    /**
     * @param container the container to set
     */
    public void setContainer(OAIFileContainer container) {
        this.container = container;
    }

}
