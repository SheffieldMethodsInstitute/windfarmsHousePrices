/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package simpleviewshed;

import java.util.ArrayList;

/**
 *
 * @author Dan Olner
 */
public class DataOutput {

    public static void outputData(DataStore data, String filename) throws Exception {

        //create a File class object and give the file the name employees.csv
        java.io.File CSV = new java.io.File(filename);

        //Create a Printwriter text output stream and link it to the CSV File
        java.io.PrintWriter outfile = new java.io.PrintWriter(CSV);

        //Header first
        String header = data.writeFieldsToCSV() + ",";
        for (String s : data.points.get(0).getExtraFieldNames()) {

            if (!s.equals("")) {
                header += (s + ",");
            }

        }

        header += "\n";

        System.out.println("header: " + header);

        outfile.write(header);

        for (Point v : data.points) {
            outfile.write(v.writeDataToCSV());
        }

        outfile.close();

    }
    
    public static void outputPointsNViz(DataStore data, String filename) throws Exception {

        //create a File class object and give the file the name employees.csv
        java.io.File CSV = new java.io.File(filename);

        //Create a Printwriter text output stream and link it to the CSV File
        java.io.PrintWriter outfile = new java.io.PrintWriter(CSV);

        //Header first
        String header = "xloc, yloc, amIseen\n";
        
        System.out.println("header: " + header);

        outfile.write(header);
        
        TargetPoint t;

        for (Point v : data.points) {
            
            t = (TargetPoint) v;            
            
            String outString = (t.x + "," + t.y + "," + t.amISeen + "\n");
            outfile.write(outString);
            
        }

        outfile.close();

    }

    public static void outputHeightsAndLineOfSight(boolean canISeeYou, ArrayList<Float> heights[], float[] line, double distance, String filename) throws Exception {

        //create a File class object and give the file the name employees.csv
        java.io.File CSV = new java.io.File(filename);

        //Create a Printwriter text output stream and link it to the CSV File
        java.io.PrintWriter outfile = new java.io.PrintWriter(CSV);

        //Header first
        if (Main.buildingHeightRun) {
            outfile.write("dist,canISeeYou,DEM plus buildings,DEM (" + (int) distance + " m),lineofsight\n");
        } else {
            outfile.write("dist,canISeeYou,DEM (" + (int) distance + " m),lineofsight\n");
        }

        for (int i = 0; i < line.length; i++) {

            if (Main.buildingHeightRun) {
                outfile.write(distance + "," + (canISeeYou ? "1" : "0") + "," + String.valueOf(heights[0].get(i))
                        + "," + String.valueOf(heights[1].get(i)) + "," + String.valueOf(line[i]) + "\n");
            } else {
                outfile.write(distance + "," + (canISeeYou ? "1" : "0") + "," + String.valueOf(heights[0].get(i)) + "," + String.valueOf(line[i]) + "\n");
            }

        }

        outfile.close();

    }

}
