class FiveBar{
  int l0; //25; // Length between origin of the two motors
  int l1; //132; // Length from motor to passive joints
  int l2; //156; // Length from passive joints to end effector
  int l3; //158; // Length between the origin Y to the center of the plate
  int boundary; //127;
  float frameSize;
  float scaleFactor;


  float[] angles = new float[2];;
  boolean record = false;
  boolean play = false;
  boolean dataSent = false;
  int nextPos;
  int mode;
  int id;

  float currentX;
  float currentY;
  float lastX;
  float lastY;
  float targetX;
  float targetY;
  float centerX;
  float centerY;

  ArrayList<PVector> path = new ArrayList<PVector>();
  int pathSize; // Change this for path length
  boolean transducerON;
  int len;

  FiveBar(int _l0, int _l1, int _l2, int _l3, int _boundary, float _centerX, float _centerY, float _frameSize, float _scaleFactor, int _id){
    l0 = _l0;
    l1 = _l1;
    l2 = _l2;
    l3 = _l3;
    id = _id;
    mode = 0;
    boundary = _boundary;
    centerX = _centerX;
    centerY = _centerY;
    scaleFactor = _scaleFactor;
    frameSize = _frameSize ;
    
    angles[0] = PI/2;
    angles[1] = PI/2;
    record = false;
    play = false;
    nextPos = 0;
    
    pathSize = 200;
    transducerON = false;
    
    // Initialize path array
    path.add( new PVector(0,l3));
    len = 1;
    
    currentX = 0;
    currentY = 0;
    lastX = 0;
    lastY = 0;
    
  }
  
  void update(){
    if (dist(mouseX, mouseY, centerX, centerY) < boundary*scaleFactor) {
      targetX = (mouseX-centerX)/scaleFactor;
      targetY = (mouseY-centerY)/scaleFactor;
    }
    
    
    len = path.size();
  
    if(record){
      if (len > 0) {
        if (dist(targetX, targetY+l3, path.get(len - 1).x, path.get(len - 1).y) > 1) {
          if (path.size() > pathSize) {
            path.remove(0);
          }
    
          path.add(new PVector(targetX, targetY+(l3)));
          currentX = targetX;
          currentY = targetY;
        }
      }
    }
    
    if(play){
    println(nextPos);
    if (nextPos < len - 1) {
      nextPos = (nextPos + 1);
    }else{
      nextPos = 0;
    }
     currentX = path.get(nextPos).x;
     currentY = path.get(nextPos).y-l3;
  }

    if(!record &&!play){
        if (dist(targetX, targetY, currentX, currentY) < 50) {
        currentX = targetX;
        currentY = targetY;
      }
    }

    
  }
  
  void display(){
   pushMatrix();
    noFill();
    translate(centerX, centerY);
    scale(scaleFactor);
    ellipse(0, 0, 20, 20);
    ellipse(0, 0, boundary * 2, boundary * 2);
    strokeWeight(5);
    rect(-frameSize/2, -frameSize/2, frameSize, frameSize);
    fill(255);
    textSize(frameSize/3);
    text(id, -frameSize/2,-frameSize/2);
    noFill();
    cursor();
    
    translate(0, -l3);

    for (int i = 0; i < len; i++) {
      stroke(255);
      circle(path.get(i).x,path.get(i).y,5);
      if (i > 0) {
        strokeWeight(1);
        line(path.get(i).x, path.get(i).y, path.get(i-1).x, path.get(i-1).y);
      }
    }
  
    plotPlot(currentX, currentY + l3);

    
    stroke(255);
    popMatrix();

  }
  
  
  //void showButtons(){
  //  pushMatrix();
  //  if(record){
  //    fill(0,200,200);
  //  }else{
  //    fill(0,50,50);
  //  }
  //  rect(coordinateX+40,coordinateY+20,50,20);
  //  fill(255);
  //  text("record",45,35);
  //  popMatrix();
    
    
  //  pushMatrix();
  //  if(play){
  //    fill(0,200,200);
  //  }else{
  //    fill(0,50,50);
  //  }
  //  rect(coordinateX+100,coordinateY+20,50,20);
  //  fill(255);
  //  text("play",105,35);
  //  popMatrix();

  //}
  
  void plotArms(float shoulder1, float shoulder2, float efx, float efy) {
  float[] p1 = {-l0 + l1 * cos(shoulder1), l1 * sin(shoulder1)};
  float[] p2 = {l0 + l1 * cos(shoulder2), l1 * sin(shoulder2)};

  line(-l0, 0, p1[0], p1[1]);
  line(p1[0], p1[1], efx, efy);
  fill(255, 0, 0);
  ellipse(efx, efy, 5, 5);

  line(l0, 0, p2[0], p2[1]);
  line(p2[0], p2[1], efx, efy);
  }
  
  void plotPlot(float efx, float efy) {
    angles = calcAngles(efx, efy);
    plotArms(angles[0], angles[1], efx, efy);
  }
  
  float[] calcAngles(float x, float y) {
    float beta1 = atan2(y, (l0 + x));
    float beta2 = atan2(y, (l0 - x));
  
    float alpha1Calc = (sq(l1) + (sq(l0 + x) + sq(y)) - sq(l2)) / (2 * l1 * sqrt(sq(l0 + x) + sq(y)));
    float alpha2Calc = (sq(l1) + (sq(l0 - x) + sq(y)) - sq(l2)) / (2 * l1 * sqrt(sq(l0 - x) + sq(y)));
  
    if (alpha1Calc > 1 || alpha2Calc > 1) {
      return new float[] {PI/2, PI/2};
    }
  
    float alpha1 = acos(alpha1Calc);
    float alpha2 = acos(alpha2Calc);
  
    float shoulder1 = beta1 + alpha1;
    float shoulder2 = PI - beta2 - alpha2;
  
    return new float[] {shoulder1, shoulder2};
  }
  
}
