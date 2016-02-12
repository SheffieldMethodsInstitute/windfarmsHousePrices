/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package simpleviewshed;

import java.awt.geom.Ellipse2D;
import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

/**
 *
 * @author SMI
 */
public class Main {

    static float[][] raster;
    boolean[][] viewShed;
    //BresenhamLine results
    ArrayList<Float> heights;
    float[] fheights;
    //Line of sight between observer and target
    float[] lineOfSight;

    Ellipse2D viewCircle;
    int observerX, observerY, targetX, targetY;
    //will need to be scaled down by five but leave here for distance band calcs
    static float radius = 15000;

    boolean canISeeYou = false;

//    ArrayList<Point> observers = new ArrayList<Point>();
//    ArrayList<Point> targets = new ArrayList<Point>();
    DataStore targets, observers;
    ArrayList<TargetPoint> targetsInRadius = new ArrayList<>();

    public Main() {

        //can be any of the three data folders, just need to get the number of files in there
        File folder = new File("data/observers");
//        File[] listOfFiles = folder.listFiles();

        //http://stackoverflow.com/questions/2102952/listing-files-in-a-directory-matching-a-pattern-in-java
        List<File> list = Arrays.asList(folder.listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.endsWith(".csv"); // or something else
            }
        }));

        System.out.println(list.size() + " file groups to process.");
        
        long startTime = System.currentTimeMillis();

        for (int fileIndex = 1; fileIndex < list.size() + 1; fileIndex++) {

            System.out.println("Loading fileset " + fileIndex + ", " + ((System.currentTimeMillis() - startTime) / 1000) + " seconds elapsed");
            loadAllData(fileIndex);

            interViz();

            try {
                DataOutput.outputData(targets, "data/output/" + fileIndex + ".csv");
            } catch (Exception e) {
                System.out.println("Data output booboo: " + e);
            }
            
        }//end for

    }

    private void interViz() {

        int obcount = 0;
        long before = System.currentTimeMillis();
        double distance2D;

        ObserverPoint observer;

        for (Point ob : observers.points) {

            observer = (ObserverPoint) ob;

            //op = (ObserverPoint) ob;
            observerX = (int) ob.x;
            observerY = (int) ob.y;

            //e.g. 15000 metres needs scaling down to 1 unit per 5 metres to match raster
            //subtract 5cm too, in case a target is exactly on 15km. Which one has been...
            float scaledRadius = (radius - 0.05f) / 5;

            viewCircle = new Ellipse2D.Float(
                    (float) observerX - scaledRadius,
                    (float) observerY - scaledRadius,
                    scaledRadius * 2, scaledRadius * 2);

            //subset targets in view circle - passing by reference, will update correctly
            targetsInRadius.clear();
            TargetPoint p;

            System.out.println("Houses total: " + targets.points.size());

            for (Point target : targets.points) {

                p = (TargetPoint) target;

                if (viewCircle.contains(p.x, p.y)) {
                    targetsInRadius.add(p);
                }
            }

            System.out.println("houses subset in 15km view: " + targetsInRadius.size());

            int timer = 0;

//        for (int i = 0; i < targets.points.size(); i++) {
            for (TargetPoint target : targetsInRadius) {

                heights = BresenhamLine.findLine(raster, observerX, observerY, (int) target.x, (int) target.y);

                //            lineOfSight = getLineOfSight(100, 2);
                //Oops: 5 metre units. That was a half-km high turbine and 10 metre high human!
                lineOfSight = getLineOfSight((100f / 5f), (2f / 5f));

                distance2D = target.twoDLocation.distance(ob.twoDLocation) * 5;

                if (distance2D < target.distanceToNearest) {
                    target.distanceToNearest = distance2D;
                }

                //Count of all distances in 1km distance bands
                //see testIndexCount method
//                if(distance2D /1000 == 15) {
////                    System.out.println("this broke it! " + distance2D);
//                    //It was exactly 15km. There should be none over that, so...
//                    //substract 50cm. If anything is still over this, we'll know about it.
//                    distance2D -= 0.5;
//                }
                target.allObsDistanceBandCounts[(int) distance2D / 1000]++;

                if (canISeeYou()) {

                    target.amISeen = true;

                    if (distance2D < target.distanceToNearestVisible) {
                        target.distanceToNearestVisible = distance2D;
                    }

                    //Hard-coding the ID for now
                    target.ICanSeeThisObserver.add(observer.id);

                    //Count of lines of sight 1km per distance band
                    //see testIndexCount method
                    target.visibleObsDistanceBandCounts[(int) distance2D / 1000]++;

                }

                //Distance from observer to target, both along ground and accounting for height
                //Scale back up to metres again!
                //target.distance3D = target.distance(ob) * 5;
                //Add distance to observer, regardless of visible or not
                //Just use 2d distance for now
                //Order will match observer file order
                target.distanceToObservers2D.add(distance2D);

            }

            System.out.println("observer " + ++obcount + ": " + observerX + "," + observerY
                    + ", time: " + ((System.currentTimeMillis() - before) / 1000) + " secs");

        }//for ob points

    }

    private void testIndexCount() {

        //Making sure distance band array index increment does what it should
        //First, is this the right number of indices e.g. if view radius is 15km?
        //0-1 / 1-2 / ... / 14-15km
        int visibleObsDistanceBandCounts[] = new int[(int) radius / 1000];

        //Yup.
        System.out.println("index num: " + visibleObsDistanceBandCounts.length);

        //Then - can distance be simply converted to int to find the right one?
        Random randDist = new Random(1);

        for (double d = 0; d < radius; d += (randDist.nextDouble() * 20)) {

            int index = (int) d / 1000;

            visibleObsDistanceBandCounts[index]++;

            //Yup!
            System.out.println("distance: " + d + ", index: " + index);

        }

    }

    private void testInterViz() {

        long before = System.currentTimeMillis();
        int id = 0;

        Random randTarget = new Random(1);

        float radius = (Landscape.height / 2) - 1;
        System.out.println("radius: " + radius);

        observerX = (Landscape.width / 2) - 1;
        observerY = (Landscape.height / 2) - 1;

        System.out.println("observer: " + observerX + "," + observerY);

        viewCircle = new Ellipse2D.Float((float) observerX - radius, (float) observerY - radius, radius * 2, radius * 2);

        for (int i = 0; i < 500000; i++) {

            if (i % 5000 == 0) {
                System.out.println("Interviz test, target:" + i + " ,"
                        + ((System.currentTimeMillis() - before) / 1000) + " secs");
            }

            targetX = -1;
            targetY = -1;

//            random points for observer to look at 
            while (!viewCircle.contains(targetX, targetY)) {

                targetX = randTarget.nextInt(Landscape.width);
                targetY = randTarget.nextInt(Landscape.height);

            }

//            System.out.println("targetX: " + targetX + ", targetY: " + targetY);
            heights = BresenhamLine.findLine(raster, observerX, observerY, targetX, targetY);
//                    fheights = BresenhamLine.findLine2(raster, x, y, i, j);

//            lineOfSight = getLineOfSight(100, 2);
            //Oops: 5 metre units. That was a half-km high turbine and 10 metre high human!
//            lineOfSight = getLineOfSight(20, 0.2f);
            lineOfSight = getLineOfSight(21, 0.2f);

            //do bespoke coordinate conversion to match raster in QGIS
            targetX = 235000 + (targetX * 5);
            targetY = 670000 - (targetY * 5);

            canISeeYou = canISeeYou();

            //targets.add(new Point(id++, targetX, targetY, canISeeYou));
            //look at some
//            if (canISeeYou) {
//            if (i % 500 == 0) {
//                try {
//                    DataOutput.outputHeightsAndLineOfSight(canISeeYou, heights, lineOfSight, ("data/lineofsight/lineOfSight_z_" + i + ".csv"));
//                } catch (Exception e) {
//                    System.out.println(e.getMessage());
//                }
//
//            }
        }

    }//end method

    private void getViewShed(int x, int y, float radius) {

        int fcount = 0, tcount = 0;

        viewShed = new boolean[Landscape.width][Landscape.height];
        viewCircle = new Ellipse2D.Float((float) x - radius, (float) y - radius, radius * 2, radius * 2);

        long before = System.currentTimeMillis();

        //Work out visibility of every point
        for (int i = 0; i < Landscape.width; i++) {

            if (i % 10 == 0) {
                System.out.println("Viewshed processing: row " + i + ", time: "
                        + ((System.currentTimeMillis() - before) / 1000) + " secs");
            }

            for (int j = 0; j < Landscape.height; j++) {

                //within view radius?
                if (viewCircle.contains(i, j)) {

                    heights = BresenhamLine.findLine(raster, x, y, i, j);
//                    fheights = BresenhamLine.findLine2(raster, x, y, i, j);
                    lineOfSight = getLineOfSight(100, 2);

                    viewShed[i][j] = canISeeYou();

                }

                //Simple check
//                if(viewShed[i][j]) {
//                    tcount++;
//                } else {
//                    fcount++;
//                }
            }
        }

//        System.out.println("True: " + tcount + ", False: " + fcount);
        System.out.println("Viewshed processing time: "
                + ((System.currentTimeMillis() - before) / 1000) + " secs");

    }

    private boolean canISeeYou() {

//        System.out.println("------------");
        //If any points on same line point are higher on the landscape
        //My view is blocked
        for (int i = 0; i < heights.size(); i++) {
//        for (int i = 0; i < fheights.length; i++) {

//            System.out.println(lineOfSight[i] + ":" + heights.get(i));
            //Will need to check this still works if ob and target height are zero
            if (heights.get(i) > lineOfSight[i]) {
//            if (fheights[i] > lineOfSight[i]) {
//                System.out.println("can't see. Height here: " + heights.get(i));

                return false;
            }

        }
//        System.out.println("can't see. Height here: " + heights.get(i));
        return true;

    }

    private float[] getLineOfSight(float obHeight, float targetHeight) {

        //We know the length of line we need.
        //Just need to interpolate values between the two endpoints
        obHeight += heights.get(0);
        targetHeight += heights.get(heights.size() - 1);

//        System.out.println("ob and target height: " + obHeight + "," + targetHeight);
        float[] line = new float[heights.size()];

//        obHeight += fheights[0];
//        targetHeight += fheights[fheights.length - 1];
//
//        System.out.println("ob and target height: " + obHeight + "," + targetHeight);
//        float[] line = new float[fheights.length];
        //So e.g. ob at 250, target at 150, line of sight drops -100
//        float rangepos = targetHeight - obHeight;
//        float range = targetHeight - obHeight;
//        float rangepos = obHeight + range;
//        
//        System.out.println("rangepos: " + rangepos);
//
//        //No trig required - straight line between two points, one dimension (well, one and a bit!)
//        for (int i = 0; i < line.length; i++) {
//
//            //line[i] = (range / (float) line.length) * (float) i;
//            line[i] = obHeight + (range * (  (float)i/(float)line.length ));
////                    ((float) i/(float) line.length);
//            
//            System.out.println("line of sight point before height adj: "
//                    + line[i]
//                    + " ---- step: " + (rangepos / (float) line.length)
//                    + ", next would be: " + (line[i] + (rangepos / (float) line.length)));
//
//        }
        //So e.g. ob at 250, target at 150, line of sight drops -100
        //Just use ob height for first index 0
        //For subsequent ones, starting from one, subtract length of index -1 so you hit target height at the last one.
        //Why? Cos the sums work then!
        float range = targetHeight - obHeight;

//        System.out.println("range: " + range);
//        System.out.println("line length: " + line.length);
        line[0] = obHeight;

        float stepSize = (range / (float) (line.length - 1));
//        System.out.println("stepSize: " + stepSize);

        //No trig required - straight line between two points, one dimension (well, one and a bit!)
        for (int i = 1; i < line.length; i++) {

            //Exclude the first value - just use obHeight for this
            line[i] = obHeight + (stepSize * (float) (i));

//            System.out.println("line of sight point before height adj: "
//                    + line[i]
//                    + " ---- step: " + (range / (float) line.length)
//                    + ", next would be: " + (line[i] + (range / (float) line.length)));
        }

        return line;

    }

    private void loadAllData(int fileNum) {

        //VERY IMPORTANT NOTE AT TOP!
        //OS Terrain 5 data is all 5 metre grids. This code as it stands HARD-CODES for that
        //Arrays/lines etc are all naturally 1-unit, of course. So values are converted:
        //e.g. 100 metre observe point is 100/5, same for target.
        //And most importantly: in the BresenhamLine class, the raster height value
        //Is divided by 5 *AS IT'S BEING COPIED INTO THE LINE ARRAY*.
        //Basically, everything is 1/5th scale to make array work easy 
        //- which national grid also makes easy by using metric
        //That's just the sort of thing I'd forget and have to spend a day tracking down.
        //
        long before = System.currentTimeMillis();

        raster = Landscape.readTiff(fileNum);

        System.out.println("Raster load time: " + ((System.currentTimeMillis() - before) / 1000) + " secs");
        //Load raster coordinate reference
        try {

            Landscape.origin = DataInput.loadCoords(fileNum);

        } catch (Exception e) {
            System.out.println("coord load failz: " + e.getLocalizedMessage());
        }

        System.out.println("origin: " + Landscape.origin[0] + "," + Landscape.origin[1]);

        try {
            targets = DataInput.loadData("data/targets/" + fileNum + ".csv", "Target", 2, 3);
//            targets = DataInput.loadData("data/targets/1.csv", "Target", 2, 3);
        } catch (Exception e) {
            System.out.println("Target load fail: " + e.getMessage());
        }

        //test with single target
//        targets.points.subList(1, targets.points.size()).clear();
//        System.out.println("single target: " + targets.points.get(0).attributes);
        //System.out.println(Point.fieldNames);
//        for (Point t : targets.points) {//
//            System.out.println("Target: " + t.attributes + "; stored locations: " + t.xloc + "," + t.yloc);//
//        }
        try {

            observers = DataInput.loadData("data/observers/" + fileNum + ".csv", "Observer", 2, 3);
//            observers = DataInput.loadData("data/observers/singleTurbine.csv", "Observer", 2, 3);

        } catch (Exception e) {
            System.out.println("Observer load fail: " + e.getMessage());
        }

        //test with single turbine
        //Nice! http://stackoverflow.com/questions/3099527/how-to-remove-everything-from-an-arraylist-in-java-but-the-first-element
        //Clear out all elements not wanted, leaving the first
//        observers.points.subList(1, observers.points.size()).clear();
//        System.out.println("single observer: " + observers.points.get(0).attributes);
//        for(Point p : observers.points) {
//            System.out.println("turbine: " + p.attributes);
//        }
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here

        new Main();

    }

}


/*
 Cuttinz

 //System.out.println(Point.fieldNames);
 //        for (Point t : observers.points) {
 //            System.out.println("Observer: " + t.attributes + "; stored locations: " + t.xloc + "," + t.yloc);
 //        }
 //System.out.println("ob field: " + observers.fields);
 //test writing
 //        try {
 //            
 //            DataOutput.outputData(observers, "data/testSave.csv");            
 ////            DataOutput.outputData(targets, "data/testSave.csv");
 //            
 //        } catch (Exception e) {
 //            System.out.println("Data write fail: " + e.getLocalizedMessage());
 //        }
 //
 //        //Test intervisibility timings.
 //        testInterViz();
 //
 //        //check true/false vals
 //        int tru = 0;
 //
 //        for (Target v : targets) {
 //            //Huh: tru++ doesn't work here.
 //            tru = (v.amISeen ? tru + 1 : tru);
 //
 //        }
 //
 //        System.out.println("True: " + tru + ", false: " + (targets.size() - tru));
 //
 //        try {
 //            DataOutput.writeIntervizCSV(targets, "data/pythonOutputRasterTest.csv");
 //        } catch (Exception e) {
 //            System.out.println("Data output booboo: " + e);
 //        }
 //viewshed from this coordinate, within circle radius
 //        getViewShed((Images.width / 2) - 1, (Images.height / 2) - 1, (Images.height / 2) - 1);
 //        Images.outputBinaryTiff(viewShed);
 */
