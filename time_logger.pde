#include <SPI.h>

const int CS = 10;  // chip select pin


void setup() {
   // initialize the serial port
   // communication between the arduino and the open log is over serial
   Serial.begin(9600);
   
   // initialize the SPI communication
   // communication between the arduino and the real time clock is over SPI
   SPI.begin();
   SPI.setBitOrder(MSBFIRST);
   SPI.setDataMode(SPI_MODE3);
   pinMode(10, OUTPUT);

   Serial.println("Begin Date Logger");
}

// this function encapsulates a write to the real time clock
void writeToSPI(int instruction, int value){
  digitalWrite(CS, LOW);
  SPI.transfer(instruction);
  SPI.transfer(value);
  digitalWrite(CS, HIGH);
}

int convertBCDtoDEC(int val){
  int seconds;
  seconds = ((val & 0xF0) >> 4) * 10;
  seconds += val & 0x0f;
  return(seconds);
}

void loop() {
  int seconds;
  int valBCD;
  
  digitalWrite(CS, LOW);
  SPI.transfer(0x00);
  valBCD = SPI.transfer(0x00);
  seconds = convertBCDtoDEC(valBCD);
  digitalWrite(CS, HIGH);
  

  Serial.println(seconds, DEC);
  
  delay(1000);
}

