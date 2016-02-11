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

    public Point(String attributes, double x, double y, double z) {

        super(x, y, z);
        
        //set mirror Point2D for 2D calcs
        twoDLocation = new Point2D.Double(x, y);

        this.attributes = attributes;

    }

    public abstract String writeDataToCSV();

    public abstract String[] getExtraFieldNames();

}
