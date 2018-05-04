class DrawSpirals implements Drawable {
  int startX, startY, finishX, finishY;
  int numRotations = 9;
  PGraphics bg;
  float value = 1;
  float hue = 1;
  boolean isWhite = true;
  boolean manual = true;
  int lastX, lastY = -1;

  int[] rawDepth;
  int depthThreshold = 10;


  DrawSpirals() {
    noStroke();
    colorMode(HSB, 1.0, 1.0, 1.0, 1.0);

    rawDepth = new int[kinect.width*kinect.height];

    bg = createGraphics(width, height);
    bg.beginDraw();
    bg.background(0);
    bg.endDraw();
    tint(0.995);

    startX = 0;
    startY = 0;
    finishX = 0;
    finishY = 0;
  }

  void draw() {

    translate(width/2, height/2);


    image(bg, -width/2, - height/2);

    rawDepth = kinect.getRawDepth();
    int closestValue = 2048;
    int closestIndex = -1;
    for (int i=0; i < rawDepth.length; i++) {
      if (rawDepth[i] < closestValue) {
        closestIndex = i;
        closestValue = rawDepth[i];
      }
    }

    int closestX = (closestIndex % kinect.width)/2;
    int closestY = (closestIndex / kinect.width)/2;
    Blob b = new Blob(closestX, closestY, closestValue);

    for (int i=closestIndex+1; i < rawDepth.length; i++) {
      if (rawDepth[i] < closestValue + depthThreshold) {
        int x = (i % kinect.width)/2;
        int y = (i / kinect.width)/2;
        if (b.isNear(x, y)) {
          b.add(x, y);
        }
      }
    }
    for (int i=closestIndex-1; i >= 0; i--) {
      if (rawDepth[i] < closestValue + depthThreshold) {
        int x = (i % kinect.width)/2;
        int y = (i / kinect.width)/2;
        if (b.isNear(x, y)) {
          b.add(x, y);
        }
      }
    }

    PVector centre = b.findCentre();
    if (centre!= null) {
      
      for (int i = 0; i < numRotations; i++) {
        rotate(TWO_PI/numRotations);
        stroke((centre.z/256)%1, 1, 1, 1);
        strokeWeight(dist(centre.x, centre.y, height/2, width/2)/15);
        //strokeWeight(2000/(centre.z));
        line(centre.x-width/2, centre.y-height/2, lastX-width/2, lastY-height/2);

        bg.beginDraw();
        bg.set(0, 0, get());
        bg.endDraw();
      }
      lastX = int(centre.x);
      lastY = int(centre.y);
    }
  }
}
