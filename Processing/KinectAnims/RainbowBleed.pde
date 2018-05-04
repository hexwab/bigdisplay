class RainbowBleed implements Drawable {

  // Depth image
  PImage depthImg;

  int[] rawDepth;

  int hue = 0;

  PGraphics pg;

  RainbowBleed() {
    background(0);
    colorMode(HSB, 255, 255, 255, 1.0);
    
    rawDepth = new int[kinect.width*kinect.height];

    pg = createGraphics(width, height);

    // Blank image
    depthImg = new PImage(width, height);
  }

  void draw() {

    // Draw the raw image
    //image(kinect.getDepthImage(), 0, 0);

    // Threshold the depth image
    rawDepth = kinect.getRawDepth();
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        int i = (y*width*2+x)*2;
        float alpha;      
        float fDepth = rawDepth[i]/2048.0;

        if (fDepth > .3 && fDepth <= .4) {
          alpha = map(fDepth, .3, .4, .5, .02);
        } else if (fDepth > .4) {
          alpha = 0.02;
        } else {
          alpha = 1.0;
        }
        depthImg.set(x,y,color((hue+rawDepth[i])%255, 255, 255, alpha));
      }
    }

    depthImg.updatePixels();

    pgDraw(pg);
    image(pg, 0, 0);

    if (frameCount % 1 == 0) {
      hue = (hue+5)%255;
    }
  }

  void pgDraw(PGraphics pg) {
    pg.beginDraw();
    pg.translate(width/2, height/2);
    pg.rotate(TWO_PI/360);
    pg.scale(1.06);
    pg.imageMode(CENTER);
    pg.image(depthImg, 0, 0);
    pg.image(pg.get(0, 0, width, height), 0, 0, width, height);
    pg.endDraw();
  }
}
