//http://www.arduino.cc/en/Reference/PortManipulation
#include <Wire.h>

int values[512]; // array to hold the values for each collection
int index;

int threshold=50;

#define SER_Pin 4   //  SER_IN    
#define RCLK_Pin 3  //  L_CLOCK  
#define SRCLK_Pin 2 //  CLOCK     

//How many of the shift registers - each board has 8 
#define number_of_74hc595s 8

int LED=8;  // alert led
int LED2=9;

//do not touch
#define numOfRegisterPins number_of_74hc595s * 8

boolean registers[numOfRegisterPins];

int request_event_number=0;

// index of each pin on the shift registers. The order is mixed up 
// because the sensors overlap 
int register_pin_vals[8][8]={
  
  {8,9,10,11,12,13,14,15},    //sr1
  {0,1,2,3,4,5,6,7},          //sr0
  {24,25,26,27,28,29,30,31},  //sr3
  {16,17,18,19,20,21,22,23},  //sr2
  {40,41,42,43,44,45,46,47},  //sr5
  {32,33,34,35,36,37,38,39},  //sr4
  {56,57,58,59,60,61,62,63},  //sr7
  {48,49,50,51,52,53,54,55},  //sr6
  
};

// 4 bit channel address for the mux channel

int muxChannel[16][4]={
  {0,0,0,0}, //channel 0
  {1,0,0,0}, //channel 1
  {0,1,0,0}, //channel 2
  {1,1,0,0}, //channel 3
  {0,0,1,0}, //channel 4
  {1,0,1,0}, //channel 5
  {0,1,1,0}, //channel 6
  {1,1,1,0}, //channel 7
  {0,0,0,1}, //channel 8
  {1,0,0,1} , //channel 9
  {0,1,0,1}, //channel 10
  {1,1,0,1}, //channel 11
  {0,0,1,1}, //channel 12
  {1,0,1,1}, //channel 13
  {0,1,1,1}, //channel 14
  {1,1,1,1}  //channel 15
};

void setup(){
  
  // join i2c bus at this address 0x10,0x20,0x30 etc.
  Wire.begin(0x20); 
  
  // do something if it is requested from the master
  Wire.onRequest(requestEvent);
  
  Wire.onReceive(receiveEvent); // register event
  
  // change clock divider to get more speed
  bitSet(ADCSRA,ADPS2) ;
  bitClear(ADCSRA,ADPS1) ;
  bitClear(ADCSRA,ADPS0) ;

  // pin modes, set digital pins as outputs
  pinMode(SER_Pin, OUTPUT);
  pinMode(RCLK_Pin, OUTPUT);
  pinMode(SRCLK_Pin, OUTPUT);
  pinMode(LED,OUTPUT);
  pinMode(LED2,OUTPUT);
  
  digitalWrite(LED2,LOW);
  
  clearRegisters();
  writeRegisters();
  getMat();
}


void loop(){
// read the mat data and save to the array
getMat();   
}

void(* resetFunc) (void) = 0;//declare reset function at address 0

// dont mess with this section.  It collects the values from each sensor
void getMat(){

  int count=0;
  
  for(int i=0;i<number_of_74hc595s;i++){
    
    //this writes all the EN pins of every multiplexer (4 per shift register) off
    
    for(int j=0;j<4;j++){  
      
    for(int k=0;k<number_of_74hc595s;k++){
      setRegisterPin(register_pin_vals[k][4],1);
      setRegisterPin(register_pin_vals[k][5],1);
      setRegisterPin(register_pin_vals[k][6],1);
      setRegisterPin(register_pin_vals[k][7],1);}
    
    for(int m=0;m<16;m++){ //each switch on the MUX

          setRegisterPin(register_pin_vals[i][0],muxChannel[m][0]);
          setRegisterPin(register_pin_vals[i][1],muxChannel[m][1]);
          setRegisterPin(register_pin_vals[i][2],muxChannel[m][2]);
          setRegisterPin(register_pin_vals[i][3],muxChannel[m][3]);
          setRegisterPin(register_pin_vals[i][4+j],0);//turn off each EN to engage the MUX
    
      writeRegisters();  //MUST BE CALLED TO DISPLAY CHANGES
      
     //values[count]=map(analogRead(A0),0,1023,0,254);     // byte mode
     values[count]=map(analogRead(A0),0,1023,0,1022);      // analog mode
     
     count+=1;
      
       }
     }
   }
 }


//set all register pins to LOW
void clearRegisters(){
  for(int i = numOfRegisterPins - 1; i >=  0; i--){
     registers[i] = LOW;
  }
} 


//Set and display registers
//Only call AFTER all values are set how you would like (slow otherwise)
//void writeRegisters(){
//
//  digitalWrite(RCLK_Pin, LOW);
//
//  for(int i = numOfRegisterPins - 1; i >=  0; i--){
//    digitalWrite(SRCLK_Pin, LOW);
//
//    int val = registers[i];
//
//    digitalWrite(SER_Pin, val);
//    digitalWrite(SRCLK_Pin, HIGH);
//
//  }
//  digitalWrite(RCLK_Pin, HIGH);
//
//}

//dont mess with this -- this is the commands to switch shift registers and multiplexers
void writeRegisters(){
//SER_Pin 4   //SER_IN  
//RCLK_Pin 3  //L_CLOCK 
//SRCLK_Pin 2 //CLOCK

//PORTD = B10101000; // sets digital pins 7,5,3 HIGH


  PORTD = B00000000; //LOW --RCLK LOW
  
  for(int i=numOfRegisterPins -1;i>=0;i--){
     PORTD = B00000000; //LOW --SRCLK LOW
     
     int val = registers[i];
     
     if (val==HIGH){
       PORTD = B00010000;
     }                        //SER PIN HIGH OR LOW
     if (val==LOW){
       PORTD = B00000000;
     }
     
     PORTD = B00000100; //SRCLK HIGH
  }
 PORTD = B00001000; //RCLK HIGH
  

}

//set an individual pin HIGH or LOW
void setRegisterPin(int index, int value){
  registers[index] = value;
}


// When the master asks for the data
void requestEvent(){
  
digitalWrite(LED,HIGH);

if(request_event_number==0){ // if this is the first time the master requests the data
  
       
        byte buffer[10]; // create a buffer. This buffer can be used to send more than only 2 bytes.
        buffer[0] = lowByte(1023);
        buffer[1] = highByte(1023);

        Wire.write(buffer,2);  // let the master know this is the beginning of the line of data
        request_event_number+=1;}
      
else{
        byte buffer[10];
        buffer[0] = lowByte(values[request_event_number-1]); // whichever number the request is on (0-512) get that index
        buffer[1] = highByte(values[request_event_number-1]);  // from the array and send it
        Wire.write(buffer,2);
      
      request_event_number+=1;
      
      if(request_event_number>512){
        request_event_number=0;}   
      
    }

digitalWrite(LED,LOW);
}


void receiveEvent(int howMany)
{ 
  while(Wire.available()) // loop through all but the last
  {
    int c = Wire.read(); // receive byte as a character
    
    if (c=100){
      digitalWrite(LED2,HIGH);
      resetFunc(); //call reset 
    }
  }
    
}

//******BYTE MODE
//void requestEvent(){
//  
//  
//digitalWrite(LED,HIGH);
//
//   
//if(request_event_number==0){
//        //getMat();
//        Wire.write(255);
//        request_event_number+=1;}
//      
//else{
//      Wire.write(values[request_event_number-1]);
//      
//      request_event_number+=1;
//      
//      if(request_event_number>512){
//        request_event_number=0;
//        activity=false;}   
//      
//    }
//
//digitalWrite(LED,LOW);
//}

//**********PACKET MODE
//void requestEvent(){
//  
//  
//digitalWrite(LED,HIGH);
//
//   
//if(request_event_number==0){
//        //getMat();
//        Wire.write(255);
//        request_event_number+=1;}
//      
//else{
//     
//      byte templist[32];
//      
//      for(int i=0;i<32;i++){
//      
//        templist[i]=values[i+32*(request_event_number-1)];}
//      
//      Wire.write(templist,32);
//      
//      request_event_number+=1;
//      
//      if(request_event_number>17){
//        request_event_number=0;
//        activity=false;}   
//      
//    }
//
//digitalWrite(LED,LOW);
//}

