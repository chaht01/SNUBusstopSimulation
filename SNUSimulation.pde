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
  
  Env normal = new Env(4);///////////////////////////////////////////////////////////////////////////////////////////////SY add pedestrian station
  normal.setRatio(new float[]{0.1, 0.1, 0.05, 0.75});
  normal.setStationDir(new float[][]{{0,1}, {0,1}, {0,1}, {0,0}});
  normal.setGuideLineDist(new float[]{5, 5, 5, 0});
  normal.setLineDistortion(new float[]{0, 0, 0, 0});
  normal.setStrictness(new float[]{4, 4, 4, 0});
  
  Env shuffled131115 = normal.copy();
  shuffled131115.shuffle(new int[]{1, 0, 2, 3});
  shuffled131115.setStationDir(new float[][]{{0,1}, {-0.5,1}, {-1,1}, {0,0}});
  shuffled131115.setGuideLineDist(new float[]{15, 10, 5, 0});
  
  Env remove5515 = normal.copy();
  remove5515.setRatio(new float[]{0.1, 0.1, 0, 0.8});
  remove5515.setStationDir(new float[][]{{-0.5,1}, {-1,1}, {0,0.0001}, {0,0}});
  remove5515.setGuideLineDist(new float[]{15, 10, 0, 0});
  remove5515.setLineDistortion(new float[]{0, 0, 0, 0});
  remove5515.setStrictness(new float[]{10, 5, 0, 0});///////////////////////////////////////////////////////////////////////////////////////////////
  
  
  envs.add(normal);
  envs.add(shuffled131115);
  envs.add(remove5515);
  
  int selectedEnvIdx = 1;
  selectedEnv = envs.get(selectedEnvIdx);
  
  for(int i=0; i<selectedEnv.stationCnt; i++){
    Attractor s = new Attractor(50+i*50, height-30);
    s.direction = selectedEnv.stationDir[i];
    s.lineDistortion = selectedEnv.lineDistortion[i];
    s.guideLineDist = selectedEnv.guideLineDist[i];
    s.col = selectedEnv.colors[i];
    s.strictness = selectedEnv.strictness[i];
    s.certified = true;
    s.isArriving = true;
    
    stations.add(s);
  }
  
  for(int i=0; i<25; i++){
    float r = random(1);
    float rangeStart = 0;
    for(int j=0; j<selectedEnv.personRatio.length; j++){
      if(rangeStart<=r && r<rangeStart+selectedEnv.personRatio[j]){
        ps.add(new Person(random(width*4/5, width), random(height/2, height), j, stations, i));
      }
      rangeStart+=selectedEnv.personRatio[j];
    }
    rangeStart = 0;
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
    if(p.fIdx != 3) p.estimate(ps);                       // get estimate path position ahead
  }
  for(Person p: ps){
    if(p.fIdx != 3) p.validateForward();                  // validate forward Person is on the way of estimate path
  }
  for(Person p: ps){
    if(p.fIdx != 3) p.findLastOfLineAndFollow(ps);          // find person(or station) who is in the last of line(certified or arrived). If found, set forward as him.
  }
  for(Person p: ps){
    if(p.fIdx != 3) p.applyBehaviors(ps);
    else p.pedestBehaviors(ps);//////////////////////////////////////////////////////////////////////////////////////////////pedestrian
    p.run();
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  float stress = 0;
  for(Person p: ps){
    if(p.fIdx != 3) stress += p.stress;
  }
  fill(50);
  text("Stress : ", width - 200, height - 50);
  text(stress, width - 100, height - 50);
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

void mousePressed() {
  for(Person p: ps){
    if(abs(p.position.x - mouseX)<10 && abs(p.position.y-mouseY)<10){
      p.debug = !p.debug;
    }
  } 
  for(int i=0; i<25; i++){
    float r = random(1);
    float rangeStart = 0;
    for(int j=0; j<selectedEnv.personRatio.length; j++){
      if(rangeStart<=r && r<rangeStart+selectedEnv.personRatio[j]){
        ps.add(new Person(random(width*4/5, width), random(height/2, height), j, stations, i));
      }
      rangeStart+=selectedEnv.personRatio[j];
    }
    rangeStart = 0;
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
      p.seeStress = false;
    } 
  }
  if (key == '2') {
    for(Person p: ps){
      if(p.fIdx != 1){
        p.seen = false;
      }else{
        p.seen = true;
      }
      p.seeStress = false;
    } 
  }
  if (key == '3') {
    for(Person p: ps){
      if(p.fIdx != 2){
        p.seen = false;
      }else{
        p.seen = true;
      }
      p.seeStress = false;
    } 
  }
  if (key == '0') {
    for(Person p: ps){
        p.seen = true;
        p.seeStress = false;
    } 
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  if (key == '4') {
    for(Person p: ps){
      p.seen = true;
      p.seeStress = true;
    } 
  }
  if (key == '7') {
    //ArrayList<Attractor> delete = new ArrayList<Attractor>();
    //Attractor temp = stations.get(0);
    //for(int i = 0; i < 5; i++) {
    //  if(temp.backward != null) 
    //}
          if(stations.get(0).backward != null){
          if(stations.get(0).backward.backward != null) {
            stations.get(0).backward.backward.forward = null;
            stations.get(0).backward.backward.certified = false;
          }
        ps.remove(stations.get(0).backward); 
        stations.get(0).backward = null;
      
    }
  }
  if (key == '8') {
    for(int i = 0; i < 1; i++) {
      if(stations.get(1).backward != null){
          if(stations.get(1).backward.backward != null) {
            stations.get(1).backward.backward.forward = null;
            stations.get(1).backward.backward.certified = false;
          }
        ps.remove(stations.get(1).backward); 
        stations.get(1).backward = null;
      }
    }
  }
  if (key == '9') {
    for(int i = 0; i < 1; i++) {
      if(stations.get(2).backward != null){
          if(stations.get(2).backward.backward != null) {
            stations.get(2).backward.backward.forward = null;
            stations.get(2).backward.backward.certified = false;
          }
        ps.remove(stations.get(2).backward); 
        stations.get(2).backward = null;
      }
    }
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}