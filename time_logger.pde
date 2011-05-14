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

int convertBCDtoDEC(int valBCD){
  int valDEC;
  valDEC = ((valBCD & 0xF0) >> 4) * 10;
  valDEC += valBCD & 0x0f;
  return(valDEC);
}

void readTime(int * seconds){
  digitalWrite(CS, LOW);
  SPI.transfer(0x00);
  int valBCD = SPI.transfer(0x00);
  *seconds = convertBCDtoDEC(valBCD);
  digitalWrite(CS, HIGH);
    
}

void loop() {
  int seconds;
  
  readTime(&seconds);

  Serial.println(seconds, DEC);
  
  delay(1000);
}

