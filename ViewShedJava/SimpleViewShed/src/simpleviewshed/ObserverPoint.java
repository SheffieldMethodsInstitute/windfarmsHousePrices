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
public class ObserverPoint extends Point {
    
    //String id;
//    public ObserverPoint(String attributes, int xloc, int yloc) {
//        super(attributes, xloc, yloc);
//    }

    public ObserverPoint(String attributes, int id, double xloc, double yloc, double zloc, int height) {
        super(attributes, id, xloc, yloc, zloc, height) ;
        
        //hard-coding ID for now, assume in first column
        //id = attributes.trim().split(",")[0];
        //System.out.println("set ob id to: " + id);
        
    }
    
    

    @Override
    public String writeDataToCSV() {
    
        return attributes + "\n";
            
    }

    public String[] getExtraFieldNames(){
        
        String[] string = {""};
        
        return string;
        
    }
    
    
    
    
    
}
