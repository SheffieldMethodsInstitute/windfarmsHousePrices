/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package simpleviewshed;

import java.io.BufferedReader;
import java.io.FileReader;

/**
 *
 * @author Dan Olner
 */
public class DataInput {

    static int x, y;

    /**
     * Don't need to mark the ID field. It's presumed these are all unique
     * points And all input fields will be returned in the final output
     *
     * Gets x and y coordinates by field index starting at zero.
     *
     * @param filename
     * @param xFieldIndex
     * @param yFieldIndex
     * @return
     * @throws Exception
     */
    public static DataStore loadData(String filename, String pointType, int xFieldIndex, int yFieldIndex) throws Exception {

//        ArrayList<Point> points = new ArrayList<Point>();
        DataStore data = new DataStore();

        BufferedReader reader = new BufferedReader(new FileReader(filename));
//        List<String> lines = new ArrayList<>();
        String line;
        String[] cells;

        boolean firstLine = true;

        while ((line = reader.readLine()) != null) {

            //read header if on first line
            if (firstLine) {
                data.fields = line;
                firstLine = false;
            } else {

                cells = line.trim().split(",");

                //raw values to be adjusted to 0,0 origin landscape image
                x = (int) Float.parseFloat(cells[xFieldIndex]);
                y = (int) Float.parseFloat(cells[yFieldIndex]);
                
                //x adjustment relatively easy
                x -= Landscape.origin[0];
                //Divide by 5 to get down to 1 index being 5 metres
                x/= 5;
                //y a bit fiddlier as we have to flip
                y -= Landscape.origin[1];
                y /= 5;
                //then flip
                y = Landscape.height - y;
                

                data.points.add(DataStore.createPoint(pointType, line, x, y, Main.raster[x][y]));
//                data.points.add(DataStore.createPoint(pointType, line,
//                        (int) Float.parseFloat(cells[xFieldIndex]),
//                        (int) Float.parseFloat(cells[yFieldIndex])
//                ));
            }
        }

        return data;

    }

    public static int[] loadCoords(int index) throws Exception {

        BufferedReader reader = new BufferedReader(new FileReader("data/coords/" + index + ".txt"));
//        List<String> lines = new ArrayList<>();
        String line;
        String[] cells;

        boolean firstLine = true;

        //only the one line
        cells = reader.readLine().trim().split(",");

        return new int[]{(int) Float.parseFloat(cells[0]), (int) Float.parseFloat(cells[1])};

    }

}
