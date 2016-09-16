package viewshed;

import java.util.ArrayList;

/**
 *
 * @author Dan Olner
 */
public class TargetPoint extends Point {

    boolean amISeen = false;
    double distance2D, distance3D;

    //list of all observers where there's line of sight
    ArrayList<Integer> ICanSeeThisObserver = new ArrayList();
    //Order of entries will match IDs passed to 
    ArrayList<Double> distanceToObservers2D = new ArrayList();
    //distance band counts for observers within the view radius. One count per index. One count per km.
    int visibleObsDistanceBandCounts[] = new int[(int) Main.radius / 1000];
    int allObsDistanceBandCounts[] = new int[(int) Main.radius / 1000];
    //distances to nearest
    double noDistToNearestFlag = 999999999;
    double distanceToNearest = noDistToNearestFlag;
    double distanceToNearestVisible = noDistToNearestFlag;
    
    public TargetPoint(String attributes, int id, double xloc, double yloc, double zloc, int height) {
        super(attributes, id, xloc, yloc, zloc, height);
    }

    @Override
    public String writeDataToCSV() {

//        System.out.println("am I seen? " + (amISeen ? 1 : 0));
        //create string containing record of observers I can see
        //delimit with vertical bar
        String visibleObs = "";

        if (!ICanSeeThisObserver.isEmpty()) {
            for (int i = 0; i < ICanSeeThisObserver.size() - 1; i++) {
                visibleObs += ICanSeeThisObserver.get(i);
                visibleObs += "|";
            }
            //Leave vertical bar off last one
            visibleObs += ICanSeeThisObserver.get(ICanSeeThisObserver.size() - 1);
        }
        
        //Two distance band counts. All within radius and visible within radius
        //A column for each count
        String allWithinRadiusCounts = "";

        for (int i = 0; i < allObsDistanceBandCounts.length - 1; i++) {
            allWithinRadiusCounts += allObsDistanceBandCounts[i];
            allWithinRadiusCounts += ",";
        }
        //Leave vertical bar off last one
        allWithinRadiusCounts += allObsDistanceBandCounts[allObsDistanceBandCounts.length - 1];
        
        //visible within radius distance band counts...
        String visibleWithinRadiusCounts = "";

        for (int i = 0; i < visibleObsDistanceBandCounts.length - 1; i++) {
            visibleWithinRadiusCounts += visibleObsDistanceBandCounts[i];
            visibleWithinRadiusCounts += ",";
        }
        //Leave vertical bar off last one
        visibleWithinRadiusCounts += visibleObsDistanceBandCounts[visibleObsDistanceBandCounts.length - 1];
        

        return attributes + ","
                + (amISeen ? 1 : 0) + ","
                + visibleObs + ","
                //                + distanceToAllObs
                + (distanceToNearest != noDistToNearestFlag ? distanceToNearest : -1) + ","
                + (distanceToNearestVisible != noDistToNearestFlag ? distanceToNearestVisible : -1) + ","
//                + distanceToNearestVisible + ","
                + allWithinRadiusCounts + ","
                + visibleWithinRadiusCounts
                + "\n";

    }

    public String[] getExtraFieldNames() {

        ArrayList<String> fields = new ArrayList<>();
        
        fields.add("canISeeAnyObs");        
        fields.add("visibleObs");        
        fields.add("distanceToNearest");        
        fields.add("distanceToNearestVisible");        
                
        //One field for each distance band
        for (int i = 0; i < Main.radius/1000; i++) {
            fields.add("allInRadius:" + Integer.toString(i) + "to" + (Integer.toString(i+1)) + "km");
        }
        
        //One field for each distance band
        for (int i = 0; i < Main.radius/1000; i++) {
            fields.add("visibleInRadius:" + Integer.toString(i) + "to" + (Integer.toString(i+1)) + "km");
        }

        return fields.toArray(new String[fields.size()]);

    }

}
