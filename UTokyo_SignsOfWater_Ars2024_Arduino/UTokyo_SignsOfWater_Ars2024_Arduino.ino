#include <Wire.h>
#include <PCA9685.h>            //PCA9685用ヘッダーファイル（秋月電子通商作成）

PCA9685 pwm = PCA9685(0x40);    //PCA9685のアドレス指定（アドレスジャンパ未接続時）
// PCA9685 pwm2 = PCA9685(0x41);   //PCA9685のアドレス指定（A0接続時）

#define SERVOMIN 150            //最小パルス幅 (標準的なサーボパルスに設定)
#define SERVOMAX 660            //最大パルス幅 (標準的なサーボパルスに設定)
int firstValues[30]; //240
int secondValues[30]; //120
int transducerStates[30];
int relayPin[30];
long lastTransducerReset = 0;
int numOfFiveBars = 8;


void setup() {
  Serial.begin(115200);
  while (!Serial) {
    ; // Wait for serial port to connect. Needed for native USB port only
  }
  Serial.println("Arduino is ready");
 pwm.begin();                   //初期設定 (アドレス0x40用)
 pwm.setPWMFreq(60);            //PWM周期を60Hzに設定 (アドレス0x40用)
//  pwm2.begin();                   //初期設定 (アドレス0x41用)
//  pwm2.setPWMFreq(60);            //PWM周期を60Hzに設定 (アドレス0x41用)

 for(int i = 0 ; i < numOfFiveBars; i++){
  firstValues[i] = 240;
  secondValues[i] = 120;
  transducerStates[i] = 0;
  relayPin[i] = 22+i;

  pinMode(relayPin[i],OUTPUT);
  digitalWrite(relayPin[i],transducerStates[i]);

  servo_write(i,firstValues[i]);
  servo_write(i*2+1,secondValues[i]);
 }
// Serial.flush();

}

int n=0;

void loop() {

 for(int i = 0 ; i < numOfFiveBars; i++){
  if(firstValues[i]<270 && secondValues[i]<270){
    servo_write(i*2,firstValues[i]);
    servo_write(i*2+1,secondValues[i]);
  }
 }
//    servo_write(0,firstValues[0]);
//    servo_write(1,secondValues[0]);

//  
//  if(millis()%10000<100){
//    digitalWrite(9,LOW);
//  }else{
//    digitalWrite(9,HIGH);
//  }

}
void servo_write(int ch, int ang){ //動かすサーボチャンネルと角度を指定
  ang = map(ang, 0, 270, SERVOMIN, SERVOMAX); //角度（0～180）をPWMのパルス幅（150～600）に変換
  pwm.setPWM(ch, 0, ang);
  // pwm2.setPWM(ch, 0, ang);
  //delay(1);
}


void serialEvent() {
//  if (Serial.available()) {
//    readDataInStrings();   
//  }

  if (Serial.available()>=6) {
    readDataInBytes();   
  }


}

void readDataInStrings(){
  String data = Serial.readStringUntil('\n');
  int id;
  // Parse the received data
  int colonIndex = data.indexOf(':');
  if(colonIndex>0){
    id = data.substring(0, colonIndex).toInt();
    Serial.println(id);
  }
  int commaIndex = data.indexOf(',');
  if (commaIndex > 1) {
    String num1Str = data.substring(colonIndex+1, commaIndex);
    String num2Str = data.substring(commaIndex + 1);
    if(num1Str == "T"){
      transducerStates[id] = num2Str.toInt();
      digitalWrite(relayPin,transducerStates[id]);
    }
    else{
      firstValues[id] = num1Str.toInt();
      secondValues[id] = num2Str.toInt();
    }
  }
}

void readDataInBytes(){
  // Read the flag byte
  byte flagByte = Serial.read();
  
  // If the flag byte is correct, read the next 4 bytes
  if (flagByte == 0xFF) {
    byte id_trans = Serial.read();
    byte highByte1 = Serial.read();
    byte lowByte1 = Serial.read();
    byte highByte2 = Serial.read();
    byte lowByte2 = Serial.read();

    // Combine the bytes into integers
    int id = id_trans >> 2;
    firstValues[id] = (highByte1 << 8) | lowByte1;
    secondValues[id] = (highByte2 << 8) | lowByte2;
    transducerStates[id] = id_trans & 0b00000011;

    // Print the values for debugging
//     Serial.print(id);
//     Serial.print(":");
//     Serial.print("Received first value: ");
//     Serial.print(firstValues[id]);
//     Serial.print(", second value: ");
//     Serial.println(secondValues[id]);

    // Send the bytes back to Processing (without the flag byte)
//    Serial.write(0xCC);
//    Serial.write(id);
//    Serial.write(highByte1);
//    Serial.write(lowByte1);
//    Serial.write(highByte2);
//    Serial.write(lowByte2);
  } else {
    // Discard any remaining bytes in the buffer if the flag byte is incorrect
    while (Serial.available() > 0) {
      Serial.read();
    }
    Serial.println("Invalid flag byte received");
  }
}
