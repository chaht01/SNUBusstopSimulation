// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Flow Field Following

class FlowField {

  // A flow field is a two dimensional array of PVectors
  PVector[][] field;
  int cols, rows; // Columns and Rows
  int resolution; // How large is each "cell" of the flow field

  FlowField(int r) {
    resolution = r;
    // Determine the number of columns and rows based on sketch's width and height
    cols = (width)/resolution;
    rows = (height)/resolution;
    field = new PVector[cols][rows];
    init();
  }
  
  void setObstacle(){
    
  }

  void init() {
    // Reseed noise so we get a new flow field every time
    noiseSeed((int)random(10000));
    float xoff = 0;
    for (int i = 0; i < cols; i++) {
      float yoff = 0;
      for (int j = 0; j < rows; j++) {
        float theta = map(noise(xoff,yoff),0,1,0,TWO_PI);
        // Polar to cartesian coordinate transformation to get x and y components of the vector
        field[i][j] = new PVector(cos(theta),sin(theta));
        yoff += 0.1;
      }
      xoff += 0.1;
    }
  }

  // Draw every vector
  void display() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        drawVector(field[i][j], i*resolution, j*resolution, resolution-2);
      }
    }

  }

  // Renders a vector object 'v' as an arrow and a position 'x,y'
  void drawVector(PVector v, float x, float y, float scayl) {
    pushMatrix();
    float arrowsize = 4;
    // Translate to position to render vector
    translate(x,y);
    stroke(0,100);
    // Call vector heading function to get direction (note that pointing to the right is a heading of 0) and rotate
    rotate(v.heading2D());
    // Calculate length of vector & scale it to be bigger or smaller if necessary
    float len = v.mag()*scayl;
    // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
    line(0,0,len,0);
    popMatrix();
  }

  PVector lookup(PVector lookup) {
   
    int column = int(constrain((lookup.x)/resolution,0,cols-1));
    int row = int(constrain((lookup.y)/resolution,0,rows-1));
    if(lookup.x<cols){
      return field[column][row].get().mult((lookup.x)/cols);
    } 
    line(lookup.x, lookup.y, lookup.x-field[column][row].get().x*resolution, lookup.y-field[column][row].get().y*resolution);
    return field[column][row].get();
  }


}
