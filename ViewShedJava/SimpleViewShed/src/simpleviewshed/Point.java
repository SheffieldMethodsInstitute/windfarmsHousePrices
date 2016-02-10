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
public abstract class Point {
    
    //Data output will include the input attributes
    //Stored as a single string
    //Field names will be the same for all
    //public static String fieldNames;
    public String attributes;
    
    int id, xloc, yloc;
    
//    public Point(int id, int xloc, int yloc, boolean amISeen) {
//        this.id = id;
//        this.xloc = xloc;
//        this.yloc = yloc;
//        this.amISeen = amISeen;
//    }

    public Point(String attributes, int xloc, int yloc) {
        this.attributes = attributes;
        this.xloc = xloc;
        this.yloc = yloc;
    }

    public abstract String writeDataToCSV();
    
    public abstract String[] getExtraFieldNames();
    
}
