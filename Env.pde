class Env{
  int stationCnt;
  float personRatio[];
  PVector stationDir[];
  float guideLineDist[];
  float lineDistortion[];
  
  Env(int cnt){
    stationCnt = cnt;
  }
  void setRatio(float a[]){
    personRatio = a;
  }
  void setStationDir(float[][] a){
    stationDir = new PVector[a.length];
    for(int i=0; i<a.length; i++){
      stationDir[i] = new PVector(a[i][0], a[i][1]);
    }
  }
  void setGuideLineDist(float a[]){
    guideLineDist = a;
  }
  void setLineDistortion(float a[]){
    lineDistortion = a;
  }
}