class Blob {
  float minx, miny, maxx, maxy, depth;
  int threshold = 10;

  Blob(float x, float y, float d) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
    depth = d;
  }

  void add(float px, float py) {
    minx = min(minx, px);
    miny = min(miny, py);
    maxx = max(maxx, px);
    maxy = max(maxy, py);
  }

  boolean isNear(float px, float py) {    
    if ((minx - threshold < px && px < maxx + threshold) && (miny - threshold < py && py < maxy + threshold)) {
      return true;
    } else {
      return false;
    }
  }

  PVector findCentre() {    
    int minSize = 10;
    int maxSize = 60;
    if (minx > 0 && miny > 0 && maxx < width && maxy < height) {
      float rectSize = max((maxx-minx), (maxy-miny));
      if (rectSize > minSize && rectSize < maxSize) {
        float cX = (minx+maxx)/2;
        float cY = (miny+maxy)/2;
        return new PVector(cX, cY, depth);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  void drawRect() {
    fill(255);
    rectMode(CORNERS);
    rect(minx, miny, maxx, maxy);
  }
}
