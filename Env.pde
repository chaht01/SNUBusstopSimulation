class Env{
  int stationCnt;
  float personRatio[];
  float interval[];
  PVector stationDir[];
  float guideLineDist[];
  float lineDistortion[];
  color colors[];
  float strictness[];
  
  Env(int cnt){
    stationCnt = cnt;
    colors = new color[cnt];
    color colormap[] = new color[]{color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(200, 200, 200), color(255, 0, 255), color(0, 255, 255)};
    for(int i=0; i<cnt; i++){
      colors[i] = colormap[i];
    }
  }
  void setRatio(float a[]){
    personRatio = a;
  }
  void setInterval(float a[]){
    interval = a;
  }
  void setStationDir(float[][] a){
    stationDir = new PVector[a.length];
    for(int i=0; i<a.length; i++){
      stationDir[i] = new PVector(a[i][0], a[i][1]).normalize();
    }
  }
  void setGuideLineDist(float a[]){
    guideLineDist = a;
  }
  void setLineDistortion(float a[]){
    lineDistortion = a;
  }
  void setStrictness(float a[]){
    strictness = a;
  }
  Env copy(){
    Env ret = new Env(stationCnt);
    ret.interval = interval.clone();
    ret.personRatio = personRatio.clone();
    ret.stationDir = stationDir.clone();
    ret.guideLineDist = guideLineDist.clone();
    ret.lineDistortion = lineDistortion.clone();
    ret.colors = colors.clone();
    ret.strictness = strictness.clone();
    return ret;
  }
  
  void shuffle(int[]order){
    if(order.length!=stationCnt){
      return;
    }
    Env copied = this.copy();
    for(int i=0; i<stationCnt; i++){
       personRatio[i] = copied.personRatio[order[i]];
       stationDir[i] = copied.stationDir[order[i]];
       guideLineDist[i] = copied.guideLineDist[order[i]];
       lineDistortion[i] = copied.lineDistortion[order[i]];
       colors[i] = copied.colors[order[i]];
       strictness[i] = copied.strictness[order[i]];
    }
  }
}