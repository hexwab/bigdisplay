
class GenerativeSpirals implements Drawable {
  float count = 0;
  float count2 = 0;

  GenerativeSpirals() {
    colorMode(HSB, 1, 1, 1, 1);
    background(0);
    noStroke();
  }

  void draw() {
    translate(width/2, height/2);
    for (int i = 0; i < 100; i++) {
      drawColourSpiral();
    }
    count = 0;
    count2 += .0001;
  }

  void drawColourSpiral() {
    fill((count2*count/50)%1, 1, abs((count2*count/5)%2-1));
    PVector v1 = getCoords(count);
    PVector v2 = getCoords(count+.3);
    PVector v3 = getCoords(count+40);
    PVector v4 = getCoords(count+40.3);
    bezier( v3.x, v3.y, v2.x, v2.y, v1.x, v1.y, v4.x, v4.y);
    count += 4.5;
  }

  PVector getCoords(float count) {
    return new PVector(count*sin(count2*count), count*cos(count2*count));
  }
}
