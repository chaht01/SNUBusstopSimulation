class Person extends Attractor {
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  float lineDistortion;
  boolean[] found;
  boolean debug;
  boolean seen;
  ArrayList<Attractor> stations;
  int fIdx;
  int tick;
  Attractor follow; // object that person follow. Initialized with bus station position
  Attractor estimateTarget;

  Person(float x, float y, int _fIdx, ArrayList<Attractor> _stations, int _n) {
    super(x, y, _n);
    tick = 0;
    maxspeed = random(0.5, 1.5);
    maxforce = 0.1;
    stations = _stations;
    fIdx = _fIdx;
    follow = stations.get(fIdx);
    r = 3;
    col = follow.col;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    certified = false;
    found = new boolean[_stations.size()];
    found[found.length-1] = false;
    lineDistortion = random(follow.lineDistortion, follow.lineDistortion*2);
    debug = false;
    seen = true;
  }

  public void run() {
    tick+=1;
    tick%=100;
    update();
    display();
  }

  void update() {
    if (!certified) {
      // Update velocity
      velocity.add(acceleration);
      // Limit speed
      velocity.limit(maxspeed);
      //velocity.x = velocity.x>0 ? velocity.x*0.1 : velocity.x;
      position.add(velocity);
      // Reset accelerationelertion to 0 each cycle
      acceleration.mult(0);
    }
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  void applyBehaviors(ArrayList<Person> ps) {
    //direction = velocity.copy().normalize();

    //estimate(ps);                       // get estimate path position ahead
    //validateForward();                  // validate forward Person is on the way of estimate path
    ////followPersonInTrackOfEstimate(ps);  // set person as forward who is on the way of estimate path
    //findLastOfLineAndFollow(ps);          // find person(or station) who is in the last of line(certified or arrived). If found, set forward as him. 

    if (forward!=null) {
      if (PVector.dist(position, forward.position) > r*3) certified = false;
    } else {
      if (PVector.dist(position, estimateTarget.position) > r*3) certified = false;
    }

    if (!certified) {
      PVector separateForce = separate(ps);
      PVector arriveForce = arrive();
      separateForce.mult(2);
      arriveForce.mult(1);
      applyForce(separateForce);
      applyForce(arriveForce);
    }
  }

  void validateForward() {
    if (forward!=null && !found[fIdx]) {
    //if (forward!=null) {  
      PVector estimatePath = PVector.sub(estimateTarget.position, position).normalize();
      PVector forwardDirection = PVector.sub(forward.position, position).normalize();

      float angle = PVector.angleBetween(estimatePath, forwardDirection);
      if (angle>30*PI/180) { // if invalid, release forward person.
        if (forward!=null) {
          forward.backward = null;
        }

        if (backward!=null) {
          backward.forward = null;
        }

        forward = null;
        backward = null;
      }
    }
  }

  void followPersonInTrackOfEstimate(ArrayList<Person> ps) {
    if (!found[fIdx]) {
      float boundaryOffset = 20;
      PVector estimatePath = PVector.sub(estimateTarget.position, position).normalize();
      ArrayList<Attractor> candidates = new ArrayList<Attractor>();
      for (Person other : ps) {
        if (other!=this) {
          if (PVector.dist(other.position, estimateTarget.position) < boundaryOffset) {
            PVector betweenDir = other.velocity.copy().normalize();
            float angle = PVector.angleBetween(PVector.sub(estimatePath, position), betweenDir);
            if (angle < 2*PI/180) {
              candidates.add(other);
            }
          }
        }
      }

      if (candidates.size()>0) {
        Attractor min = candidates.get(0);
        for (Attractor c : candidates) {
          if (PVector.dist(min.position, position) > PVector.dist(c.position, position)) {
            min = c;
          }
        }
        if (backward!=null) {
          backward.forward = null;
          backward = null;
        }
        if (forward!=null) {
          forward.backward = null;
          forward = null;
        }

        setForward(min);
        min.debugged = true;
      }
    }
  }
  void findStation(ArrayList<Person> ps){
    for (int i=0; i<found.length; i++) {
      if (found[i]) {
        continue;
      } else {
        Attractor station = stations.get(i);
        PVector towardStation = PVector.sub(station.position, position);
        ArrayList<Attractor> candidates = new ArrayList<Attractor>();
        for (Person other : ps) {
          if (other!=this) {
            if (PVector.dist(other.position, station.position) < towardStation.mag()) {
              PVector towardOther = PVector.sub(other.position, position);
              float theta = PVector.angleBetween(towardStation, towardOther);
              float dist = abs(towardOther.mag()*sin(theta));
              if (dist < r*3) {
                candidates.add(other);
              }
            }
          }
        }
        if (candidates.size()>0) {
          found[i] = false;
        } else {
          found[i] = true;
        }
      }
    }
  }
  void findLastOfLineAndFollow(ArrayList<Person> ps) {
    Attractor[] minDistCandidates = new Attractor[]{null, null, null};
    for (int i=0; i<found.length; i++) {
      if (found[i]) {
        continue;
      } else {
        Attractor station = stations.get(i);
        PVector towardStation = PVector.sub(station.position, position);
        ArrayList<Attractor> candidates = new ArrayList<Attractor>();
        for (Person other : ps) {
          if (other!=this) {
            if (PVector.dist(other.position, station.position) < towardStation.mag()) {
              PVector towardOther = PVector.sub(other.position, position);
              float theta = PVector.angleBetween(towardStation, towardOther);
              float dist = abs(towardOther.mag()*sin(theta));
              if (dist < r*3) {
                candidates.add(other);
              }
            }
          }
        }
        if (candidates.size()>0) {
          found[i] = false;
        } else {
          found[i] = true;
        }

        for (int j=candidates.size()-1; j>=0; j--) {
          if (!candidates.get(j).certified && !candidates.get(j).isArriving) {
            candidates.remove(j);
          }
        }
        if (candidates.size()>0) {
          Attractor min = candidates.get(0);
          for (Attractor c : candidates) {
            if (PVector.dist(min.position, position) > PVector.dist(c.position, position)) {
              min = c;
            }
          }      
          minDistCandidates[i] = min;
        } else {
          if (found[fIdx]) {
            text("-", position.x, position.y);
          } else {
            text("+", position.x, position.y);
          }
        }
      }
    }

    
      if (!found[fIdx]) {
        if (minDistCandidates[fIdx]!=null) {
          Attractor lastCertified = lastAttractorOfLine(minDistCandidates[fIdx]);
          if(lastCertified!=null){
            //tempLastCertified.col = color(255, 255, 0);
            //println("1!");
            Attractor temp = lastCertified;
            boolean isAnotherLine = false;
            while(temp.forward!=null){
              temp = temp.forward;
            }
            
            for(int i=0; i<found.length; i++){
              if(i!=fIdx && found[i] && stations.get(i).equals(temp)){
                isAnotherLine = true;
                break;
              }
            }
            if(!isAnotherLine){
              found[fIdx] = true;
              //col = color(255, 0, 255); //purple
              setForward(lastAttractorOfLine(stations.get(fIdx)));
            }
          }
          else{
            //setForward(lastCertified);
          //println("1");
          }
        } else {
          Attractor lastCertified = lastAttractorOfLine(stations.get(fIdx));
          if(lastCertified!=null){
            //col = color(255, 255, 0); //yellow
            //println("2@");
            setForward(lastCertified);
          }else{
          //println("2");
        }
          
        }
      } else {
        Attractor lastCertified = lastAttractorOfLine(stations.get(fIdx));
        if(lastCertified!=null){
          //col = color(0, 255, 255); //cyan
          setForward(lastCertified);
          //println("3#");
        }else{
          //println("3");
        }
      }
    
  }


  void setForward(Attractor attr) {
    Attractor uncertain = attr;
    if (uncertain!=null) {
      //Check distance from estimate path from attr
      //If it exceed some value, skip setting forward process.
      float intervalSize = getIntervalSize();
      Attractor tempTarget;
      tempTarget = attr.copy();
      float distBWpath = PVector.dist(position, tempTarget.position);
      boolean skip = false;
      float maximumDist = 10*intervalSize;
      while(true){
        tempTarget.position = PVector.sub(tempTarget.position, tempTarget.direction.copy().normalize().setMag(3*intervalSize));
        tempTarget.direction = tempTarget.direction.copy().normalize().rotate(tempTarget.lineDistortion);  //set direction
        if (tempTarget.direction.heading()<0) {
          tempTarget.direction = new PVector(-1, 0);
        }
        if (PVector.dist(position, tempTarget.position) < maximumDist) {
          break;
        }
        if(PVector.dist(position, tempTarget.position) - distBWpath > 0){
          skip = true;
          break;
        }else{
          rect(tempTarget.position.x, tempTarget.position.y, 5, 5);
          distBWpath = PVector.dist(position, tempTarget.position);
        }
      }
      if(!skip){
        // set forward process.
        boolean inserted = false;
        while (uncertain.backward!=null && !uncertain.backward.equals(this)) {
          float diff = PVector.dist(uncertain.position, uncertain.backward.position) - PVector.dist(uncertain.position, position);
          if (diff>0) {
            if (this.forward!=null) {
              this.forward.backward = null;
              this.forward = null;
            }
            if (this.backward!=null) {
              this.backward.forward = null;
              this.backward = null;
            }
            this.backward = uncertain.backward;
            this.backward.forward = this;
            uncertain.backward = this;
            this.forward = uncertain;
            inserted = true;
            break;
          } else {
            uncertain = uncertain.backward;
          }
        }
        if (!inserted) {
          uncertain.backward = this;
          forward = uncertain;
        }
      }
    }else{
      if(forward!=null){
         forward.backward = null;
         forward = null;
      }
      if(backward!=null){
        backward.forward = null;
        backward = null;
      }
    }
    
    
    
    //check validation
    for(int i=0; i<stations.size(); i++){
      Attractor checker = stations.get(i);
      while(checker.backward!=null){
        if(checker.backward.forward==null || !checker.backward.forward.equals(checker)){
          //throw link error
          checker.backward = null;
        }else{
          checker = checker.backward;
        }
      }
    }
  }



  boolean certify() {
    boolean certifyOk = false;
    Attractor curr = this;
    while(curr.forward!=null){
      if(curr.forward.certified){
        curr = curr.forward;
      }else{
        return certifyOk;
      }
    }
    if(!curr.certified){
      return certifyOk;
    }
    certified = true;
    certifyOk = true;
    //direction = forward.direction.copy();  //set direction
    if(!forward.equals(stations.get(fIdx))){
      direction = forward.velocity.copy().normalize().rotate(lineDistortion);  //set direction
      velocity = direction.copy();
    }else{
      direction = velocity.copy().normalize();
    }
    return certifyOk;
  }


  Attractor lastAttractorOfLine(Attractor start) {
    Attractor curr = start;
    while (curr.backward!=null && !curr.backward.equals(this) && (curr.backward.certified)) {
      curr = curr.backward;
    }
    if(!curr.certified){
      return null;
    }
    return curr;
  }

  void estimate(ArrayList<Person> ps) {
    float intervalSize = getIntervalSize();
    Attractor tempTarget = new Attractor();
    int cnt = found[fIdx] ? (int)stations.get(fIdx).guideLineDist : (int)stations.get(fIdx).guideLineDist+5;  //11.24
    tempTarget = lastAttractorOfLine(stations.get(fIdx)).copy();
    

    for (int i=0; i<cnt; i++) {
      tempTarget.position = PVector.sub(tempTarget.position, tempTarget.direction.copy().normalize().setMag(intervalSize));
      tempTarget.direction = tempTarget.direction.copy().normalize().rotate(lineDistortion);  //set direction
      if (tempTarget.direction.heading()<0) {
        tempTarget.direction = new PVector(-1, 0);
      }
      if (PVector.dist(position, tempTarget.position) < 10*intervalSize) {
        break;
      }
    }

    
    estimateTarget = tempTarget;


    if (certified) {
      fill(estimateTarget.col);
      rect(estimateTarget.position.x, estimateTarget.position.y, 4, 4);
    } else {
      fill(estimateTarget.col);
      ellipse(estimateTarget.position.x, estimateTarget.position.y, 4, 4);
    }
  }




  // A method that calculates a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector arrive() {
    float intervalSize = getIntervalSize();
    Attractor _target = forward==null ? estimateTarget : forward;
    PVector target = PVector.sub(_target.position, _target.direction.copy().rotate(lineDistortion).setMag(2*intervalSize));
    //PVector target = _target.position;
    float arriveDistance = intervalSize*4; //40
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    float d = desired.mag();
    // Scale with arbitrary damping within 100 pixels
    if (d < arriveDistance) {
      float m = map(d, 0, arriveDistance, 0, maxspeed);
      isArriving = true;
      if (m<0.25) {  //critical to distortion shape
          if(certify()){
            return new PVector(0, 0);
          }
      }
      desired.setMag(m);
    } else {
      isArriving = false;
      desired.setMag(maxspeed);
    }
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }


  PVector separate (ArrayList<Person> boids) {
    float distanceFromAttractor = PVector.dist(estimateTarget.position, position);
    float desiredseparation = getIntervalSize()*2;
    float periphery = PI/2;
    PVector avgVel = new PVector(0, 0);
    PVector steer = new PVector(0, 0);
    if (distanceFromAttractor < getIntervalSize()*4) {  
      return steer;
    }
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Person other : boids) {
      if (other!=this && !other.isArriving) {
        PVector comparison = PVector.sub(other.position, position);

        // How far is it
        float d = PVector.dist(position, other.position);

        // What is the angle between the other boid and this one's current direction
        float diff = PVector.angleBetween(comparison, velocity);
        // If it's within the periphery and close enough to see it
        if (diff < periphery && d > 0 && d < desiredseparation && !other.certified) {
          PVector diff2 = PVector.sub(position, other.position);
          avgVel.add(other.velocity);
          diff2.normalize();
          diff2.div(d);        // Weight by distance
          steer.add(diff2);
          count++;            // Keep track of how many
        }
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      float contourDistance = 150;
      steer.div((float)count);
      avgVel.div((float)count);
      if (contourDistance < distanceFromAttractor && avgVel.mag() < velocity.mag()) {
        float headingBetween = velocity.heading() - avgVel.mag();
        PVector contour;
        if (headingBetween > 0 ) {
          contour = velocity.copy().rotate(PI/6);
        } else {
          contour = velocity.copy().rotate(-PI/6);
        }
        contour.normalize();
        steer.add(contour);
      }
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }


  void display() {
    if(seen){
      // Draw a triangle rotated in the direction of velocity
      //if(debug){
      if (forward!=null) {
        forward.debugged = true;
      }
      //}
      if (debugged) {
        //col = color(255, 0, 255);
      }
  
  
      float theta = velocity.heading() + radians(90);
      
      if(certified){
        col = color(0, 255, 255);
      }
      fill(col);
      noStroke();
      pushMatrix();
      translate(position.x, position.y);
      rotate(theta);
      beginShape(TRIANGLES);
      vertex(0, -r*2);
      vertex(-r, r*2);
      vertex(r, r*2);
      endShape();
      popMatrix();
  
  
  
      int cnt = -1;
      if (forward!=null) {
        Attractor curr = stations.get(fIdx);
        while (curr!=null) {
          if (curr.equals(this)) {
            break;
          }
          cnt++;
          curr = curr.backward;
        }
        if (cnt!=-1) {
          text(cnt, position.x, position.y);
        }
      }
  
      
      text(name, position.x, position.y+10);
      String s = "";
      Attractor tmp = stations.get(fIdx);
      
      while(tmp.backward!=null){
        s+= tmp.backward.name +" ";
        tmp = tmp.backward;
      }
      text(s, 50, 20+10*fIdx);
      
      if (certified) {
        fill(0);
        text("!!", position.x, position.y-10);
      }
      
    }
    
  }

  float getIntervalSize() {
    return (r*3);
  }
}



//case 1 : when tracking line is possible : estimate destination of line according to the information of the number of people in front of view
//case 2 : when it is impossible to trackng line : Get streesed and,
//     2-1 : count the number of lines and choose one