import org.openkinect.freenect.*; //<>//
import org.openkinect.processing.*;
import java.util.LinkedList;

Drawable anim;
Kinect kinect;

void setup() {
  frame.setLocation(0,0);
  size(320, 240);
  
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.enableMirror(true);
  
  anim = new ParticlesAnim(5000);
}

void draw() {
  anim.draw();
}

// Adjust the angle and the depth threshold min and max
void keyPressed() {
  if (key == '1'){
    anim = new ParticlesAnim(5000);
  }
  else if (key == '2'){
    anim = new RainbowEdges();
  }
  else if (key == '3'){
    anim = new RainbowBleed();
  }
  else if (key == '4'){
    anim = new ScrollingPattern();
  }
  else if (key == '5'){    
    anim = new DrawSpirals();    
  }
  else if (key == '6'){    
    anim = new GenerativeSpirals();
  }
  else if (key == '7'){
    anim = new ReactionDiff();
  }
}
