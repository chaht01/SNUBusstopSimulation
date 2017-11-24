// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// One vehicle "arrives"
// See: http://www.red3d.com/cwr/

ArrayList<Person> ps;
ArrayList<Attractor> stations;
ArrayList<Env> envs;
Env selectedEnv;

void setup() {
  size(800, 500);
  ps = new ArrayList<Person>();
  stations = new ArrayList<Attractor>();
  envs = new ArrayList<Env>();
  
  Env normal = new Env(3);
  normal.setRatio(new float[]{0.3, 0.2, 0.5});
  normal.setStationDir(new float[][]{{0,1}, {-0.5,1}, {-1,1}});
  normal.setGuideLineDist(new float[]{15, 10, 5});
  normal.setLineDistortion(new float[]{0, 0, 0});
  
  Env shuffled = new Env(3);
  shuffled.setRatio(new float[]{0.3, 0.2, 0.5});
  shuffled.setStationDir(new float[][]{{0,1}, {-0.5,1}, {-1,1}});
  shuffled.setGuideLineDist(new float[]{5, 10, 3});
  shuffled.setLineDistortion(new float[]{0, 0, 0});
  
  Env remove5515 = new Env(2);
  remove5515.setRatio(new float[]{0.3, 0.2});
  remove5515.setStationDir(new float[][]{{-0.5,1}, {-1,1}});
  remove5515.setGuideLineDist(new float[]{15, 10});
  remove5515.setLineDistortion(new float[]{0, 0});
  
  
  envs.add(normal);
  envs.add(shuffled);
  envs.add(remove5515);
  
  int selectedEnvIdx = 2;
  selectedEnv = envs.get(selectedEnvIdx);
  
  for(int i=0; i<selectedEnv.stationCnt; i++){
    Attractor s = new Attractor(50+i*50, height-30);
    s.direction = selectedEnv.stationDir[i];
    s.lineDistortion = selectedEnv.lineDistortion[i];
    s.guideLineDist = selectedEnv.guideLineDist[i];
    s.certified = true;
    s.isArriving = true;
    stations.add(s);
  }
  
  stations.get(0).col = color(255, 0, 0);
  stations.get(1).col = color(0, 255, 0);
  //stations.get(2).col = color(0, 0, 255);
  for(int i=0; i<25; i++){
    ps.add(new Person(random(width*4/5, width), random(height/2, height), (int)random(selectedEnv.stationCnt), stations, i));
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
    ps.add(new Person(random(width*4/5, width), random(height/2, height), (int)random(selectedEnv.stationCnt), stations, i));
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