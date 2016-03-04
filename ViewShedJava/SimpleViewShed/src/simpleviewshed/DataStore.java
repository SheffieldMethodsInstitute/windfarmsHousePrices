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
public class DataStore {
    
    public String fields;
    public ArrayList<Point> points = new ArrayList<Point>();    
    
    public String writeFieldsToCSV(){        
        return fields;        
    }
    
    public ArrayList<Point> getPoints(){
        return points;
    }
    
    /**
     * Factory-ish code
     */
    public static Point createPoint(String type, String attributes, int xloc, int yloc, float zloc, int height){
        
        if(type.equals("Target")){
            return new TargetPoint(attributes, xloc, yloc, zloc, height);
        } else if(type.equals("Observer")){
            return new ObserverPoint(attributes, xloc, yloc, zloc, height);
        }
        
        return null;
        
    }

}
