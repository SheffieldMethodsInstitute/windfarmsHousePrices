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

    public static void outputHeightsAndLineOfSight(boolean canISeeYou, ArrayList<Float> heights, float[] line, String filename) throws Exception {

        //create a File class object and give the file the name employees.csv
        java.io.File CSV = new java.io.File(filename);

        //Create a Printwriter text output stream and link it to the CSV File
        java.io.PrintWriter outfile = new java.io.PrintWriter(CSV);

        //Header first
        outfile.write("canISeeYou,heights,lineofsight\n");

        for (int i = 0; i < line.length; i++) {

            outfile.write((canISeeYou ? "1" : "0") + "," + String.valueOf(heights.get(i)) + "," + String.valueOf(line[i]) + "\n");

        }

        outfile.close();

    }

}
