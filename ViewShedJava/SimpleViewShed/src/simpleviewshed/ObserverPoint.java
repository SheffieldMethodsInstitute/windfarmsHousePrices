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
    
    //boolean amISeen = false;

    public ObserverPoint(String attributes, int xloc, int yloc) {
        super(attributes, xloc, yloc);
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
