#include <Wire.h>

unsigned long initial;
unsigned long final;

int count=0;
int c;

void setup()
{
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(115200);  // start serial for output

//
  Wire.beginTransmission(0x10); // transmit to device #4
  Wire.write(100);              // sends one byte  
  Wire.endTransmission();    // stop transmitting
  
//  Wire.beginTransmission(0x20); // transmit to device #4
//  Wire.write(100);              // sends one byte  
//  Wire.endTransmission();    // stop transmitting
//  
//  
  delay(2000); //give the master a second to boot up
  
  
}


void loop()
{

//get data from each of the 4 mats.  Comment out each block as needed.
Serial.print("one ");
request(0x10);
delay(50);
//
//Serial.print("two ");
//request(0x20);
//delay(50);

//Serial.print("three ");
//request(0x30);
//delay(50);
//
//Serial.print("four ");
//request(0x40);
//delay(50);


}

//********ANALOG MODE***Read in analog values from the slave boards
void request(int ID){

  //initial = millis();
  
  Wire.requestFrom(ID, 2);    // request 1 byte from slave device given in the ID
  if( Wire.available() == 2){        // if the two bytes are available
   byte low = Wire.read();            // read a byte of the buffer
   byte high = Wire.read();           // read the next byte of the buffer.
   c = word (high, low);     // generate a two byte number
   //Serial.println(c);  
  
}

if(c==1023){  //if a 1023 is recieved
  for(int i=0;i<512;i++){       //repeat 512 times for each sensor value
    Wire.requestFrom(ID, 2);    //request a two byte number (0-1022) from the slave
  
   if( Wire.available() == 2){        // if the two bytes are available
   byte low = Wire.read();            // read a byte of the buffer
   byte high = Wire.read();           // read the next byte of the buffer.
   int result = word (high, low);     // generate a two byte number
   Serial.print(String(result));      // print the result as a string
   Serial.print(" ");
   count+=1;}                // print a space
  
    else {
    Serial.println("Didn't get two bytes");
    }
  }
    Serial.println("");   // print a new line
    //Serial.println(count);
    //count=0;
 }

//Serial.println(millis()-initial);

}


//******BYTE MODE
//void request(int ID){
//
//  initial = millis();
//  
//  Wire.requestFrom(ID, 1);    // request 6 bytes from slave device #2
//  while(Wire.available()){
//  c = Wire.read(); //look for the first 255
//  }
//
//if(c==255){
//  for(int i=0;i<512;i++){
//    Wire.requestFrom(ID, 1);    // request 6 bytes from slave device #2
//  
//    while(Wire.available()){
//
//    int c = Wire.read();
//    Serial.print(c);
//    Serial.print(" ");}
//    }
//    Serial.println("");
// }
//
//Serial.println(millis()-initial);
//
//}

//*******PACKETMODE
//void request(int ID){
//
//  initial = millis();
//  
//  Wire.requestFrom(ID, 1);    // request 6 bytes from slave device #2
//  while(Wire.available()){
//  c = Wire.read(); //look for the first 255
//  }
//
//if(c==255){
//  for(int i=0;i<16;i++){
//    Wire.requestFrom(ID, 32);    // request 6 bytes from slave device #2
//  
//    while(Wire.available()){
//
//    int c = Wire.read();
//    Serial.print(c);
//    Serial.print(" ");}
//    }
//    Serial.println("");
// }
//
//Serial.println(millis()-initial);
//
// 
//}
