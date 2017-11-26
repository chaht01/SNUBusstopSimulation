// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// One vehicle "arrives"
// See: http://www.red3d.com/cwr/

ArrayList<Person> ps;
ArrayList<Attractor> stations;
ArrayList<Env> envs;
Env selectedEnv;
float stressPool;
int totalTick;
int tick;
int seconds;

int peopleOutletCnt;
int dispenseIntervalMinutes;
int dispenseIntervalTickMulted;
int dispenseTick;

boolean triggerOutlet;

float systemSpeed = 6;


int minutesToTicks(float minute){
  return (int)((minute/systemSpeed)*60*60);
}
void setup() {
  frameRate(60);
  totalTick = 0;
  tick = 0;
  seconds = 0;
  peopleOutletCnt = 0;
  dispenseIntervalMinutes = 6;
  dispenseIntervalTickMulted = minutesToTicks(dispenseIntervalMinutes);//frame
  
  
  dispenseTick = 0;
  triggerOutlet = true;
  size(1600, 350);
  
  ps = new ArrayList<Person>();
  stations = new ArrayList<Attractor>();
  envs = new ArrayList<Env>();
  
  Env normal = new Env(4);
  normal.setRatio(new float[]{0.1, 0.1, 0.05, 0.75});
  normal.setInterval(new float[]{50,450,850,-10});
  normal.setStationDir(new float[][]{{-1,1}, {-1,1}, {-1,1}, {0,0}});
  normal.setGuideLineDist(new float[]{5, 5, 5, 0});
  normal.setLineDistortion(new float[]{PI/180, PI/180, PI/180, 0});
  normal.setStrictness(new float[]{12, 12, 12, 0});
  normal.setStartTick(new int[]{minutesToTicks(1), minutesToTicks(2), minutesToTicks(2), minutesToTicks(100)});
  normal.setMarginalTick(new int[]{minutesToTicks(7), minutesToTicks(7), minutesToTicks(5), minutesToTicks(1000)});
  
  Env shuffled151113 = normal.copy();
  shuffled151113.shuffle(new int[]{2, 0, 1, 3});
  shuffled151113.setStationDir(new float[][]{{-4,1}, {-4,1}, {-10,1}, {0,0}});
  shuffled151113.setGuideLineDist(new float[]{15, 10, 5, 0});
  
  Env shuffled111513 = normal.copy();
  shuffled111513.shuffle(new int[]{0, 2, 1, 3});
  shuffled111513.setStationDir(new float[][]{{-4,1}, {-4,1}, {-10,1}, {0,0}});
  shuffled111513.setGuideLineDist(new float[]{15, 10, 5, 0});
  
  Env remove5515 = normal.copy();
  remove5515.setRatio(new float[]{0.1, 0, 0.1, 0.8});
  remove5515.setInterval(new float[]{50,50,650,-10});
  remove5515.setStationDir(new float[][]{{-4,1}, {-4,1}, {-5,1}, {0,0}});
  remove5515.setGuideLineDist(new float[]{15, 0, 10, 0});
  remove5515.setLineDistortion(new float[]{0, 0, 0, 0});
  remove5515.setStrictness(new float[]{10, 0, 5, 0});
  
  Env moved1 = normal.copy();
  moved1.setInterval(new float[]{50,250,850,-10});
  
  Env moved2 = normal.copy();
  moved2.setInterval(new float[]{50,650,850,-10});
  
  Env guideLined = normal.copy();
  guideLined.setStationDir(new float[][]{{0,1}, {-0,5,1}, {-0.75,1}, {0,0}});
  guideLined.setGuideLineDist(new float[]{50, 25, 5, 0});
  guideLined.setLineDistortion(new float[]{4*PI/180, 5*PI/180, 6*PI/180, PI/180});
  
  envs.add(normal);
  envs.add(shuffled151113);
  envs.add(shuffled111513);
  envs.add(remove5515);
  envs.add(moved1);
  envs.add(moved2);
  envs.add(guideLined);
  
  int selectedEnvIdx = 6;
  selectedEnv = envs.get(selectedEnvIdx);
  
  for(int i=0; i<selectedEnv.stationCnt; i++){
    Attractor s = new Attractor(selectedEnv.interval[i], height-30);
    s.direction = selectedEnv.stationDir[i];
    s.lineDistortion = selectedEnv.lineDistortion[i];
    s.guideLineDist = selectedEnv.guideLineDist[i];
    s.col = selectedEnv.colors[i];
    s.strictness = selectedEnv.strictness[i];
    s.certified = true;
    s.isArriving = true;
    
    stations.add(s);
  }

}

void draw() {
  background(255);
  if(tick/60>=1){
    tick%=60;
    seconds++;
  }
  
  /**
   *  Subway dispense time events
   **/
  if(dispenseTick >dispenseIntervalTickMulted){
    dispenseTick = 0;
    triggerOutlet = true;
  }
  if(triggerOutlet == true){
    peopleOutletCnt += (int)(random(30*dispenseIntervalMinutes, 50*dispenseIntervalMinutes));
    triggerOutlet = false;
  }
  // People spend about 84ticks to go through unseen distance(4.625m)
  if(totalTick%84==0 && peopleOutletCnt>0){
    int currOutlet = peopleOutletCnt>=10 ? 10 : peopleOutletCnt;
    peopleOutletCnt -= currOutlet;
    for(int i=0; i<currOutlet; i++){
      float r = random(1);
      float rangeStart = 0;
      for(int j=0; j<selectedEnv.personRatio.length; j++){
        if(rangeStart<=r && r<rangeStart+selectedEnv.personRatio[j]){
          ps.add(new Person(random(width-150, width), random(height/3, height-50), j, stations, i));
        }
        rangeStart+=selectedEnv.personRatio[j];
      }
      rangeStart = 0;
    }
  }
  
  
  /**
   * Bus stop dispense time event
   **/
   for(int i=0; i<selectedEnv.stationCnt; i++){
     if(selectedEnv.ticks[i] > selectedEnv.marginalTick[i]){
       selectedEnv.ticks[i] = 0;
       selectedEnv.triggerRide[i] = true;
     }
     if(selectedEnv.triggerRide[i]){
       
       selectedEnv.accomodate[i] += (int)random(15,25);
       selectedEnv.triggerRide[i] = false;
     }
     if(stations.get(i).backward==null || !stations.get(i).backward.everCertified){
       selectedEnv.accomodate[i] =0;
     }else{
       if(selectedEnv.accomodate[i]>0 && stations.get(i).isReady){
         stations.get(i).isReady = false;
          riding(i);
          selectedEnv.accomodate[i]--;
       }
     }
     selectedEnv.ticks[i]++;
   }
  
  
  
  tick++;
  dispenseTick++;
  totalTick++;
  
  
  
  text(frameRate, width-60, 30);
  text(seconds, width-60, 60);
  
  
  
  
  PVector mouse = new PVector(mouseX, mouseY);

  // Draw an ellipse at the mouse position
  fill(200);
  noStroke();
  //ellipse(mouse.x, mouse.y, 48, 48);
  for(Attractor s: stations){
    s.display();
  }

  float stress = 0;
  for(Person p: ps){
    if(p.fIdx != 3) stress += p.stress;
  }
  fill(50);
  textSize(20);
  text("Stress : ", width - 200, height - 20);
  text(stress + stressPool, width - 130, height - 20);
  textSize(10);
  
  // Call the appropriate steering behaviors for our agents
  ArrayList<Person> toRemove = new ArrayList<Person>();
  for(Person p: ps){
    if(p.fIdx ==3 && p.position.x<0){
      toRemove.add(p);
    }
  }
  for(int i=toRemove.size()-1; i>=0;i--){
    Person removing = toRemove.get(i);
    ps.remove(removing);
    toRemove.remove(i);
    removing = null;
  }
  
  for(Person p: ps){
    p.direction = p.velocity.copy().normalize();
  }
  for(Person p: ps){
    if(p.fIdx != 3) p.estimate(ps);                       // get estimate path position ahead
  }
  for(Person p: ps){
    if(p.fIdx != 3 && !p.everCertified) p.validateForward();                  // validate forward Person is on the way of estimate path
  }
  for(Person p: ps){
    if(p.fIdx != 3 && !p.everCertified) p.findLastOfLineAndFollow(ps);          // find person(or station) who is in the last of line(certified or arrived). If found, set forward as him.
  }
  for(Person p: ps){
    if(p.fIdx != 3) p.applyBehaviors(ps);
    else p.pedestBehaviors(ps);
    p.run();
  }
}

void riding(int stationIdx){
  if(stations.get(stationIdx).backward != null){
      Attractor delPerson = stations.get(stationIdx).backward;
      Attractor pointer = delPerson;
        while(pointer.backward!=null && pointer.backward.everCertified){
        pointer.backward.everForward = pointer.copy();
        pointer = pointer.backward;
      }
      if(delPerson.backward != null) {
        delPerson.backward.forward = stations.get(stationIdx);
        stations.get(stationIdx).backward = delPerson.backward;
      }
      else if(delPerson.backward == null) stations.get(stationIdx).backward = null;
      stressPool += delPerson.stress;
      ps.remove(delPerson);
      delPerson = null;
      
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
  if (key == '4') {
    for(Person p: ps){
      p.seen = true;
      p.seeStress = true;
    } 
  }
  
  /**
   * ride on the bus
   */
  if (key == '7') {
      
      if(stations.get(0).backward != null){
      
      Attractor delPerson = stations.get(0).backward;
      Attractor pointer = delPerson;
        while(pointer.backward!=null && pointer.backward.everCertified){
        pointer.backward.everForward = pointer.copy();
        pointer = pointer.backward;
      }
      if(delPerson.backward != null) {
        delPerson.backward.forward = stations.get(0);
        stations.get(0).backward = delPerson.backward;
      }
      else if(delPerson.backward == null) stations.get(0).backward = null;
      stressPool += delPerson.stress;
      ps.remove(delPerson);
      delPerson = null;
      
    }
  }
  if (key == '8') {
    if(stations.get(1).backward != null){
        stations.get(1).busStopped = true;
        Attractor delPerson = stations.get(1).backward;
        Attractor pointer = delPerson;
      while(pointer.backward!=null && pointer.backward.everCertified){
        pointer.backward.everForward = pointer.copy();
        pointer = pointer.backward;
      }
        if(delPerson.backward != null) {
          delPerson.backward.forward = stations.get(1);
          stations.get(1).backward = delPerson.backward;
        }
        else if(delPerson.backward == null) stations.get(1).backward = null;
        stressPool += delPerson.stress;
        ps.remove(delPerson);
        delPerson = null;
    }
  }
  if (key == '9') {
    if(stations.get(2).backward != null){
      Attractor delPerson = stations.get(2).backward;
      Attractor pointer = delPerson;
      while(pointer.backward!=null && pointer.backward.everCertified){
        pointer.backward.everForward = pointer.copy();
        pointer = pointer.backward;
      }
      if(delPerson.backward != null) {
        delPerson.backward.forward = stations.get(2);
        stations.get(2).backward = delPerson.backward;
      }
      else if(delPerson.backward == null) stations.get(2).backward = null;
      stressPool += delPerson.stress;
      ps.remove(delPerson);
      delPerson = null;
    }
  }
  
  
}