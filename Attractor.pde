class Attractor {
  PVector position;
  PVector direction;
  PVector velocity;
  color col;
  float lineDistortion;
  Attractor forward;
  Attractor backward;
  boolean certified;
  boolean isArriving;
  boolean debugged;
  float guideLineDist;
  float strictness;
  float stress;
  int name;
  Attractor(){}
  Attractor(float x, float y){
    position = new PVector(x, y);
    direction = new PVector(0, 0);
    velocity = new PVector(0, 0);
    forward = null;
    backward = null;
    certified = false;
    isArriving = false;
    name = -1;
  }
  Attractor(float x, float y, int _n){
    position = new PVector(x, y);
    direction = new PVector(0, 0);
    velocity = new PVector(0, 0);
    forward = null;
    backward = null;
    certified = false;
    isArriving = false;
    name = _n;
  }
  void display(){
    //ellipse(position.x, position.y, 6, 6);
    float theta = direction.heading2D() + radians(90);
      
      stroke(0);
      pushMatrix();
      translate(position.x,position.y);
      rotate(theta);
      beginShape(TRIANGLES);
      vertex(0, -2);
      vertex(-2, 2);
      vertex(2, 2);
      endShape();
      popMatrix();
      PVector target = PVector.sub(position, direction.copy().mult(15));
      ellipse(target.x, target.y, 4, 4);
  }
  
  Attractor copy(){
    Attractor ret = new Attractor(position.x, position.y);
    ret.direction = direction.copy();
    ret.col = col;
    ret.velocity = velocity.copy();
    //ret.forward = forward!=null ? forward : null;
    //ret.backward = backward!=null ? backward:null;
    ret.certified = certified;
    ret.isArriving = isArriving;
    ret.name = name;
    return ret;
  }
}