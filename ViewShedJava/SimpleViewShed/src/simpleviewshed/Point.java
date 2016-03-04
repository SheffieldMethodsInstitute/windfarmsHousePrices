/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package simpleviewshed;

import java.awt.geom.Point2D;
import javax.vecmath.Point3d;

/**
 *
 * @author Dan Olner
 */
public abstract class Point extends Point3d {

    public String attributes;
    //Mirror 2D point for 2D dist calcs
    public Point2D.Double twoDLocation;
    public int height;

    /**
     * Just to confuse matters: x coordinate is the point's position on the DEM surface
     * Height is its own height in metres, not its absolute height.
     * Are we clear?
     * 
     * @param attributes
     * @param x
     * @param y
     * @param z
     * @param height 
     */
    public Point(String attributes, double x, double y, double z, int height) {

        super(x, y, z);
        this.height = height;
        
        //set mirror Point2D for 2D calcs
        twoDLocation = new Point2D.Double(x, y);

        this.attributes = attributes;

    }

    public abstract String writeDataToCSV();

    public abstract String[] getExtraFieldNames();

}
