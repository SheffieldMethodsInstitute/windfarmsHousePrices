/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package simpleviewshed;

import java.awt.Color;
import java.awt.image.*;
import java.io.File;
import javax.imageio.ImageIO;

/**
 *
 * @author Dan Olner
 */
public class Images {

    public static int width, height;

    public static float[][] readTiff() {

        BufferedImage image = new BufferedImage(1, 1, 1);

        try {

            //Needs https://github.com/jai-imageio/jai-imageio-core
            //I used standalone jar from
            //https://bintray.com/jai-imageio/maven/jai-imageio-core-standalone/view
//            image = ImageIO.read(new File("rasters/test.tif"));
//            image = ImageIO.read(new File("rasters/testSingleTile2.tif"));
//            image = ImageIO.read(new File("rasters/bigRasterFromMultiBuffer.tif"));
            image = ImageIO.read(new File("rasters/bigRasterFromMultiBuffer2.tif"));

            //RGB outputs as a 32 bit int. We want 32 bit float.
//            float fl = Float.intBitsToFloat(i);
//            System.out.println("And in float form: " + fl);
//            
        } catch (Exception e) {
            System.out.println("uh oh: " + e.getLocalizedMessage());
        }

        width = image.getWidth();
        height = image.getHeight();

        System.out.println("height: " + height);
        System.out.println("width: " + width);

//        int i = image.getRGB(1000, 1000);
//        System.out.println("RGB: " + i);
        Raster r = image.getData();

        //Pixels are 32 bit float encoded, metres above sea level
//        float[] pix = r.getPixel(2001, 0, (float[]) null);
//
//        for (float f : pix) {
//            System.out.println("pix: " + f);
//        }
        //Bucket into array (much faster access than r.getPixel, tested)
        float pixels[][] = new float[image.getWidth()][image.getHeight()];

        for (int i = 0; i < image.getWidth(); i++) {
            for (int j = 0; j < image.getHeight(); j++) {
                pixels[i][j] = r.getPixel(i, j, (float[]) null)[0];
            }
        }

        //System.out.println("pixtest: " + pixels[2002][0]);
        return pixels;

    }

    public static boolean outputBinaryTiff(boolean[][] bits) {

        BufferedImage output = new BufferedImage(width, height, BufferedImage.TYPE_BYTE_BINARY);

        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {

                //http://stackoverflow.com/questions/27633299/bufferedimage-type-byte-binary-change-color-of-pixel
                output.setRGB(i, j, bits[i][j] ? Color.WHITE.getRGB() : Color.BLACK.getRGB());
                
            }
        }

        //http://stackoverflow.com/questions/30320434/write-a-tiff-with-jai
        File outputfile = new File("rasters/viewshed.tif");

        try {
            ImageIO.write(output, "TIFF", outputfile);
        } catch (Exception e) {
            System.out.println("Bah! " + e.getMessage());
            return false;
        }

        return true;

    }

}
