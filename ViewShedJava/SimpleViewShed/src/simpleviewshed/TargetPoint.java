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
public class TargetPoint extends Point {

    boolean amISeen = false;
    double distance2D, distance3D;

    //list of all observers where there's line of sight
    ArrayList<String> ICanSeeThisObserver = new ArrayList();
    //Order of entries will match IDs passed to 
    ArrayList<Double> distanceToObservers2D = new ArrayList();
    //distance band counts for observers within the view radius. One count per index. One count per km.
    int visibleObsDistanceBandCounts[] = new int[(int) Main.radius/1000];
    int allObsDistanceBandCounts[] = new int[(int) Main.radius/1000];

//    public TargetPoint(String attributes, int xloc, int yloc) {
//        super(attributes, xloc, yloc);
//    }
    public TargetPoint(String attributes, double xloc, double yloc, double zloc) {
        super(attributes, xloc, yloc, zloc);
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

        //Same for all distances to obs (regardless of visible or not)
        String distanceToAllObs = "";

        if (!distanceToObservers2D.isEmpty()) {
            for (int i = 0; i < distanceToObservers2D.size() - 1; i++) {
                distanceToAllObs += distanceToObservers2D.get(i);
                distanceToAllObs += "|";
            }
            //Leave vertical bar off last one
            distanceToAllObs += distanceToObservers2D.get(distanceToObservers2D.size() - 1);
        }

        return attributes + ","
                + visibleObs + ","
                + distanceToAllObs
                + "\n";
//        return attributes + ","
//                + (amISeen ? 1 : 0) + ","
//                + distance2D + ","
//                + distance3D
//                + "\n";

    }

    public String[] getExtraFieldNames() {

        String[] string = {"visibleObs,distancesToAllObs_2D"};

        return string;

    }

}
