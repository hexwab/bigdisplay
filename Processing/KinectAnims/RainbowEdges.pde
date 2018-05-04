class RainbowEdges implements Drawable {

  // Depth image
  PImage depthImg;

  int hue = 0;

  int[] rawDepthLast;

  RainbowEdges() {
    background(0);
    colorMode(HSB, 255, 255, 255, 255.0);
	noTint();

    rawDepthLast = new int[kinect.width*kinect.height];

    depthImg = new PImage(kinect.width, kinect.height);
  }

  void draw() {
    int[] rawDepth = kinect.getRawDepth();

    for (int i=0; i < rawDepth.length; i += 2) {
      if (abs(rawDepth[i] - rawDepthLast[i]) >= 100) {
        depthImg.pixels[i] = color((hue+rawDepth[i]/8)%255, 255, 255);
      } else {
        depthImg.pixels[i] = color(0, 10);
      }
    }

    System.arraycopy(rawDepth, 0, rawDepthLast, 0, 640*480);

    // Draw the thresholded image
    depthImg.updatePixels();  
    image(depthImg, 0, 0, width, height);



    if (frameCount % 1 == 0) {
      hue = (hue+5)%255;
    }
  }
}
