// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// One vehicle "arrives"
// See: http://www.red3d.com/cwr/

ArrayList<Person> ps;
ArrayList<Attractor> stations;

void setup() {
  size(800, 500);
  ps = new ArrayList<Person>();
  stations = new ArrayList<Attractor>();
  stations.add(new Attractor(50, height-30));
  stations.add(new Attractor(100, height-30));
  stations.add(new Attractor(150, height-30));
  float distortion = 0;
  for(Attractor s: stations){
    s.direction = new PVector(-1, 1);
    s.lineDistortion = distortion;
    //distortion += 1*PI/180;
    s.certified = true;
    s.isArriving = true;
  }
  stations.get(0).col = color(255, 0, 0);
  stations.get(1).col = color(0, 255, 0);
  stations.get(2).col = color(0, 0, 255);
  for(int i=0; i<25; i++){
    ps.add(new Person(random(width*4/5, width), random(height/2, height), (int)random(3), stations, i));
  }
  
  
}

void draw() {
  background(255);
  PVector mouse = new PVector(mouseX, mouseY);

  // Draw an ellipse at the mouse position
  fill(200);
  noStroke();
  //ellipse(mouse.x, mouse.y, 48, 48);
  for(Attractor s: stations){
    s.display();
  }


  // Call the appropriate steering behaviors for our agents
  
  for(Person p: ps){
    p.direction = p.velocity.copy().normalize();
  }
  for(Person p: ps){
    p.estimate(ps);                       // get estimate path position ahead
  }
  for(Person p: ps){
    p.validateForward();                  // validate forward Person is on the way of estimate path
  }
  for(Person p: ps){
    p.findLastOfLineAndFollow(ps);          // find person(or station) who is in the last of line(certified or arrived). If found, set forward as him.
  }
  for(Person p: ps){
    p.applyBehaviors(ps);
    p.run();
  }
}

void mousePressed() {
  for(Person p: ps){
    if(abs(p.position.x - mouseX)<10 && abs(p.position.y-mouseY)<10){
      p.debug = !p.debug;
    }
  } 
  for(int i=0; i<20; i++){
    ps.add(new Person(random(width*4/5, width), random(height/2, height), (int)random(3), stations, i));
  }
}

void keyPressed() {
  if (key == '1') {
    for(Person p: ps){
      if(p.fIdx != 0){
        p.seen = false;
      }else{
        p.seen = true;
      }
    } 
  }
  if (key == '2') {
    for(Person p: ps){
      if(p.fIdx != 1){
        p.seen = false;
      }else{
        p.seen = true;
      }
    } 
  }
  if (key == '3') {
    for(Person p: ps){
      if(p.fIdx != 2){
        p.seen = false;
      }else{
        p.seen = true;
      }
    } 
  }
  if (key == '0') {
    for(Person p: ps){
        p.seen = true;
      
    } 
  }
}