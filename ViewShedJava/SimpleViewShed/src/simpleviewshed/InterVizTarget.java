/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package simpleviewshed;

/**
 *
 * @author Dan Olner
 */
public class InterVizTarget {

    int id, xloc, yloc;
    boolean amISeen;

    public InterVizTarget(int id, int xloc, int yloc, boolean amISeen) {
        this.id = id;
        this.xloc = xloc;
        this.yloc = yloc;
        this.amISeen = amISeen;
    }

    //Like totally nabbed from http://stackoverflow.com/questions/22795903/writing-an-array-to-a-csv-file-java
    public String toCSVString() {
        
        return id + ","
                + (amISeen ? 1 : 0) + ","
                + xloc + ","
                + yloc
                + "\n";
        
    }

    public static String CSVHeader() {
        
        return("id,amIseen,xloc,yloc\n");
                
    }

}
