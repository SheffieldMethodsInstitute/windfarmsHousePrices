package viewshed;

import java.io.Serializable;
import java.util.ArrayList;

/**
 *
 * @author Dan Olner
 */
public class DataStore implements Serializable {
    
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
    public static Point createPoint(String type, String attributes, int id, int xloc, int yloc, float zloc, int height){
        
        if(type.equals("Target")){
            return new TargetPoint(attributes, id, xloc, yloc, zloc, height);
        } else if(type.equals("Observer")){
            return new ObserverPoint(attributes, id, xloc, yloc, zloc, height);
        }
        
        return null;
        
    }

}
