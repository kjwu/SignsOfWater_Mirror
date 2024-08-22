import processing.serial.*;

boolean simulate = false;
boolean dataSent = false;
float scaleFactor = 0.13;
float[] angles = {PI/2, PI/2};

Serial myPort;  // Create object from Serial class
byte[] byteData = new byte[6]; // 1 flag byte + 1 id/transducer byte + 4 angle bytes 

int numOfFB = 8;

FiveBar[] fiveBars = new FiveBar[numOfFB];
float[][] centers = {
  {2452,267},{1578,497},{2732,1219},{690,1391},{1748,1781},{2553,2515},{70,2527},{966,2757},
  {3288,3267},{2282,3618},{1273,3830},{295,4035}, {2398,5031},{966,5347},{2068,6113},{3483,6267},
  {4238,2515},{5384,3188},{6365,3364},{4791,4205},{3653,4267},{5825,4861},{3898,5177},{4898,5938},
  {3483,82},{4791,437},{5554,1017},{4122,1391},{5072,1956},{6122,2121}

};
 
void setup() {
  size(845, 845);
  pixelDensity(2);
  frameRate(20);
  
  for(int i = 0; i<numOfFB;i++){
    fiveBars[i] = new FiveBar(25,132,156,158,127,centers[i][0]*scaleFactor,centers[i][1]*scaleFactor,340,scaleFactor,i);
  }
  
  if (!simulate) {
    String portName = Serial.list()[7];
    myPort = new Serial(this, portName, 115200);
    myPort.buffer(6); // Buffer 4 bytes before triggering serialEvent

    printArray(Serial.list());
    myPort.clear();
  }
}

void draw() {
  
  background(0);
  
  for(int i = 0; i<numOfFB;i++){
    fiveBars[i].update();
    fiveBars[i].display();

  }
  
  
  if (!simulate) {
    
    //if (!dataSent) {
      for(int i = 0; i < numOfFB; i++){
        //if(!fiveBars[i].dataSent){
        //sendData(i, int(360-degrees(fiveBars[i].angles[0])), int(180-degrees(fiveBars[i].angles[1])));
        sendDataInBytes(i, int(360-degrees(fiveBars[i].angles[0])), int(180-degrees(fiveBars[i].angles[1])),0);

        //fiveBars[i].dataSent = true;
        }
      //}
    //}
  }
  
  
  //if(myPort.available()>0){
  //  String echo = myPort.readStringUntil('\n');
  //  try{
  //    int num = Integer.valueOf(echo.trim());
  //    println(num);
  //    //fiveBars[num].dataSent = false;
  //  }catch(Exception e){
  //    ;
  //  }
  //}
}



//void keyPressed() {
//  if (key == 'f' || key == 'F') {
//    performance = !performance;
//  }
  
//  if (key == 't' || key == 'T'){
//        transducerON = !transducerON;
//    sendData('T', transducerON ? 1 : 0);
//  }
  
//  if (key == 'r' || key == 'R'){
//        record = !record;
//        play = false;
//  }
  
//  if (key == 'p' || key == 'P'){
//        play = !play;
//        record = false;
//  }
  
//  if (key == 'c' || key == 'C'){
//    path.clear();
//    path.add(new PVector(currentX, currentY+(l3)));
//    nextPos = 0;
//  }
  
//}


void sendData(int id, int firstVal, int secondVal) {
    String dataToSend = str(id)+":"+str(firstVal)+","+str(secondVal)+"\n";
    myPort.write(dataToSend);
}



void sendDataInBytes(int id, int firstVal, int secondVal, int thirdVal){
  // Create a byte array with 6 bytes (1 flag byte + 1 id + trans byte+ 4 angle data bytes )
  byteData[0] = (byte) 0xFF; // Flag byte
  byteData[1] = (byte) (id << 6 | thirdVal);
  byteData[2] = (byte) (firstVal >> 8); // High byte of first value
  byteData[3] = (byte) (firstVal & 0xFF); // Low byte of first value
  byteData[4] = (byte) (secondVal >> 8); // High byte of second value
  byteData[5] = (byte) (secondVal & 0xFF); // Low byte of second value
  

  // Send the byte array to the Arduino
  myPort.write(byteData);
}


void serialEvent(Serial p) {
  //String echo = p.readStringUntil('\n');
  //if(echo != null){
  //  try{
  //    int num = Integer.valueOf(echo.trim());
  //    println(num);
  //    fiveBars[num].dataSent = false;
  //  }catch(Exception e){
  //    ;
  //  }
  //}


  if (p.read() == 0xCC) {


    byte[] incomingData = new byte[5];
    p.readBytes(incomingData);

    int id = incomingData[0];
    //println(incomingData[0]+","+incomingData[1]+","+incomingData[2]+","+incomingData[3]);
    int receivedFirstValue = (incomingData[1] << 8) | (incomingData[2] & 0xFF);
    int receivedSecondValue = (incomingData[3] << 8) | (incomingData[4] & 0xFF);

    if (receivedFirstValue <1023 && receivedSecondValue<1023) {
      println("Received - ID: " +id+ " First value: " + receivedFirstValue + ", Second value: " + receivedSecondValue);
    }
  }
  // Reset the flag to send new values  
  dataSent = false;


//  if(p.available()>0){
//    int echo = p.read();
//    if(echo < 30){
//      fiveBars[echo].dataSent = false;
//      print(echo);
//    }
//  }
//  if (p.read() == 0xCC) {


//    byte[] incomingData = new byte[4];
//    p.readBytes(incomingData);

//    //println(incomingData[0]+","+incomingData[1]+","+incomingData[2]+","+incomingData[3]);
//    int receivedFirstValue = (incomingData[0] << 8) | (incomingData[1] & 0xFF);
//    int receivedSecondValue = (incomingData[2] << 8) | (incomingData[3] & 0xFF);

//    if (receivedFirstValue <1023 && receivedSecondValue<1023) {
//      println("Received - First value: " + receivedFirstValue + ", Second value: " + receivedSecondValue);
//    }
//  }
//  // Reset the flag to send new values  
//  dataSent = false;
}

//void toggle(boolean theFlag) {
//  if(theFlag==true) {
//    col = color(255);
//  } else {
//    col = color(100);
//  }
//  println("a toggle event.");
//}
