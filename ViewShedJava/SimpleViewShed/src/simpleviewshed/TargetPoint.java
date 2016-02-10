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
public class TargetPoint extends Point {

    boolean amISeen = false;

    public TargetPoint(String attributes, int xloc, int yloc) {
        super(attributes, xloc, yloc);
    }

    @Override
    public String writeDataToCSV() {

//        System.out.println("am I seen? " + (amISeen ? 1 : 0));

        return attributes + ","
                + (amISeen ? 1 : 0)
                + "\n";
        
    }

    public String[] getExtraFieldNames() {

        String[] string = {"AmISeen"};

        return string;

    }

}
