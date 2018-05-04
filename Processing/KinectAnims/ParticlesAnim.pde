import blobDetection.*; //<>//

class ParticlesAnim implements Drawable{  
  int[] rawDepth;
  int depthThreshold = 10;
  ParticleSystem ps;

  ParticlesAnim(int particleCount) {
    background(0);
    colorMode(HSB, 255, 255, 255, 1.0);
    background(0);

    noStroke();
    
    rawDepth = new int[kinect.width*kinect.height];

    ps = new ParticleSystem(particleCount);
  }

  void draw() {
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
      ps.setGravity(centre);
    }

    ps.update();
    
    fill(0, .07);
    rect(0, 0, width, height);
    ps.draw();
    if (centre != null) {
      fill(255);
      ellipse(centre.x, centre.y, 10, 10);
    }
  }
}

class ParticleSystem {
  ArrayList<Particle> particles = new ArrayList<Particle>();

  ParticleSystem(int count) {
    for (int i = 0; i < count; i++) {
      addParticle();
    }
  }

  void addParticle() {
    particles.add(new Particle(random(0, width), random(0, height), random(0, 2048)));
  }

  void setGravity(PVector centrePos) {
    for (Particle p : particles) {
      PVector grav = new PVector(centrePos.x-p.pos.x, centrePos.y-p.pos.y, centrePos.z-p.pos.z);
      
      grav.setMag(30/grav.mag());
      p.setGravity(grav);
    }
  }
  
  void setAcceleration(PVector acc) {
    for (Particle p : particles) {
      p.setAcceleration(acc);
    }
  }

  void update() {
    for (int i = particles.size()-1; i >= 0; i--) {
      if (particles.get(i).lifespan < 0) {
        particles.remove(i);
      } else {
        particles.get(i).update();
      }
    }
  }

  void draw() {
    for (Particle p : particles) {
      p.draw();
    }
  }
}

class Particle {
  PVector pos, vel, acc, grav;
  float terminalVel = 4.5 + random(-.1,.1);
  int lifespan = 255;

  Particle(float x, float y, float z) {
    pos = new PVector(x, y, z);
    vel = new PVector(0, 0, 0);
    acc = new PVector(0, 0, 0);
    grav = new PVector(0, 0, 0);
    lifespan += random(-50, 50);
  }

  void update() {
    vel.add(grav);
    vel.add(acc);

    if (vel.mag() > terminalVel) {
      vel.setMag(terminalVel);
    }

    pos.add(vel);

    // wrap
    pos.x = (pos.x+width)%width;
    pos.y = (pos.y+height)%height;
    pos.z = (pos.z+2048)%2048;

    //lifespan--;
  }

  void setAcceleration(PVector v) {
    acc = v;
  }
  
  void setVelocity(PVector v) {
    vel = v;
  }

  void setGravity(PVector v) {
    grav = v;
  }

  void draw() {
    
    set(int(pos.x), int(pos.y), color((pos.z/2)%255,255,255));
    
  }
}
