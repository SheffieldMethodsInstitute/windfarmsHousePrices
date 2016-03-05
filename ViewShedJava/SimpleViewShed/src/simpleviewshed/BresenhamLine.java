package simpleviewshed;

import java.util.ArrayList;
import java.util.List;

/**
 * Implementation of the Bresenham line algorithm.
 *
 * @author fragkakis
 *
 * https://github.com/fragkakis/bresenham/blob/master/src/main/java/org/fragkakis/Bresenham.java
 */
public class BresenhamLine {

    //Don't know length of line yet
    public static ArrayList line = new ArrayList<Float>();
    //same line for building-height version. Can do both at same time.
    public static ArrayList bh_line = new ArrayList<Float>();

//    /**
//     * Returns the list of array elements that comprise the line.
//     *
//     * @param grid the 2d array
//     * @param x0 the starting point x
//     * @param y0 the starting point y
//     * @param x1 the finishing point x
//     * @param y1 the finishing point y
//     * @return the line as a list of array elements
//     */
//    public static <T> List<T> findLine(T[][] grid, int x0, int y0, int x1, int y1) {
//
//        List<T> line = new ArrayList<T>();
//
//        int dx = Math.abs(x1 - x0);
//        int dy = Math.abs(y1 - y0);
//
//        int sx = x0 < x1 ? 1 : -1;
//        int sy = y0 < y1 ? 1 : -1;
//
//        int err = dx - dy;
//        int e2;
//        int currentX = x0;
//        int currentY = y0;
//
//        while (true) {
//            line.add(grid[currentX][currentY]);
//
//            if (currentX == x1 && currentY == y1) {
//                break;
//            }
//
//            e2 = 2 * err;
//            if (e2 > -1 * dy) {
//                err = err - dy;
//                currentX = currentX + sx;
//            }
//
//            if (e2 < dx) {
//                err = err + dx;
//                currentY = currentY + sy;
//            }
//        }
//
//        return line;
//    }
    /**
     * Returns the list of array elements that comprise the line.
     *
     * @param grid the 2d array
     * @param x0 the starting point x
     * @param y0 the starting point y
     * @param x1 the finishing point x
     * @param y1 the finishing point y
     * @return the line as a list of array elements
     */
    //return height values along the line
    //Return two arraylists if finding for building height raster also
    public static ArrayList<Float>[] findLine(int x0, int y0, int x1, int y1) {
//    public static ArrayList<Float>[] findLine(float[][] grid, int x0, int y0, int x1, int y1) {

        line.clear();

        //If using building heights too
        //I can grab both at the same time rather than calculate twice. 
        //It should be a little faster.
        if (Main.useBuildingHeights) {
            bh_line.clear();
        }
//        ArrayList line = new ArrayList<>();        

        int dx = Math.abs(x1 - x0);
        int dy = Math.abs(y1 - y0);

        int sx = x0 < x1 ? 1 : -1;
        int sy = y0 < y1 ? 1 : -1;

        int err = dx - dy;
        int e2;
        int currentX = x0;
        int currentY = y0;

        while (true) {

            line.add(Main.raster[currentX][currentY]);

            //find same point height on building-height version, if using
            if (Main.useBuildingHeights) {
                bh_line.add(Main.bh_raster[currentX][currentY]);
            }
//            line.add(grid[currentX][currentY]/5f);

//            System.out.println("grid: " + grid[currentX][currentY] + ", grid/5: " + grid[currentX][currentY]/5f);
            if (currentX == x1 && currentY == y1) {
                break;
            }

            e2 = 2 * err;
            if (e2 > -1 * dy) {
                err -= dy;
                currentX += sx;
            }

            if (e2 < dx) {
                err += dx;
                currentY += sy;
            }
        }

        if (Main.useBuildingHeights) {
            return new ArrayList[]{line, bh_line};
        } else {
            return new ArrayList[]{line};
        }

    }

    //return height values along the line
    public static float[] findLine2(float[][] grid, int x0, int y0, int x1, int y1) {

        //Bresenham line is only ever the max out of x and y
        //Plus one!
        float[] line
                = (Math.abs(x0 - x1) > Math.abs(y0 - y1)
                        ? new float[Math.abs(x0 - x1) + 1]
                        : new float[Math.abs(y0 - y1) + 1]);

//        System.out.println("line length: " + line.length);
        int index = 0;

        int dx = Math.abs(x1 - x0);
        int dy = Math.abs(y1 - y0);

        int sx = x0 < x1 ? 1 : -1;
        int sy = y0 < y1 ? 1 : -1;

        int err = dx - dy;
        int e2;
        int currentX = x0;
        int currentY = y0;

        while (true) {

            line[index++] = (grid[currentX][currentY]);

            if (currentX == x1 && currentY == y1) {
                break;
            }

            e2 = 2 * err;
            if (e2 > -1 * dy) {
                err = err - dy;
                currentX = currentX + sx;
            }

            if (e2 < dx) {
                err = err + dx;
                currentY = currentY + sy;
            }
        }

        return line;

    }
}
