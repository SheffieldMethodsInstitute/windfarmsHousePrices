package viewshed;

/**
 *
 * @author Dan Olner
 */
public class ObserverPoint extends Point {
    
    public ObserverPoint(String attributes, int id, double xloc, double yloc, double zloc, int height) {
        super(attributes, id, xloc, yloc, zloc, height) ;
        
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
