class ScrollingPattern implements Drawable {
  PImage pg;
  int scaledX = 160;
  int scaledY = 120;

  int threshold = 800;

  ScrollingPattern() {
    background(0);
    noSmooth();

    frameRate(25);

    // To efficiently set all the pixels on screen, make the set() 
    // calls on a PImage, then write the result to the screen.
    pg = new PImage(scaledX, scaledY);

    colorMode(HSB, 1.0f, 1.0f, 1.0f);

    //frameRate(1);
  }

  void draw() {
    background(0);
    // fiddle with HSV
    int hueInt, satInt;
    float hue, sat;

    int[] rawDepth = kinect.getRawDepth();

    //pg.beginDraw();
    for (int x = 0; x < scaledX; x += 1) {
      for (int y = 0; y < scaledY; y += 1) {
        //int y = 0;

        int i = (y*width*2+x)*4;

        if (rawDepth[i] < threshold) {

          int x2 = (int)((y + scaledX - x + rawDepth[i]/6)+frameCount);
          int y2 = (int)((x + y + rawDepth[i]/6)+frameCount);

          hueInt = (y2 & x2 | y2 + x2);

          satInt = y2 ^ x2 ^ (y2 & (x2 + 1));

          hue = (float) Math.abs(Math.tan(Math.toRadians(x2|y2)));
          sat = (float) Math.abs(Math.sin(Math.toRadians(y2|x2)));

          if (hue <0.5f) {
            hue = normaliser0to1(hueInt, x2 & y2) % 1;
            sat = normaliser0to1(satInt, 256) % 1;
          } else
          if (sat < 0.5f) {
            hue = normaliser0to1(hueInt, x2 |y2) % 1;
            sat = normaliser0to1(satInt, 256) % 1;
          }
          color c = color(hue%1, 1, (hue*sat)%1);

          pg.set(x, y, c);
        } else {
          pg.set(x, y, 0);
        }
      }
    }
    //pg.endDraw();

    //image(get(0, 0, width, height), 0, -2);
    //image(pg, 0, height-2, width, 2);
    image(resizeBasic(pg, 2), 0, 0);
  }
  
  private float normaliser0to1(float d, int modRange) {
    return (d % modRange) / modRange;
  }

  PImage resizeBasic(PImage in, int factor) {
    PImage out = createImage(in.width * factor, in.height * factor, RGB);
    in.loadPixels();
    out.loadPixels();
    for (int y=0; y<in.height; y++) {
      for (int x=0; x<in.width; x++) {
        int index = x + y * in.width;
        for (int h=0; h<factor; h++) {
          for (int w=0; w<factor; w++) {
            int outdex = x * factor + w + (y * factor + h) * out.width;
            out.pixels[outdex] = in.pixels[index];
          }
        }
      }
    }
    out.updatePixels();
    return out;
  }  
}
