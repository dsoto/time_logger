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

// converts a binary coded decimal to a decimal
int convertBCDtoDEC(int valBCD){
  int valDEC;
  valDEC = ((valBCD & 0xF0) >> 4) * 10;
  valDEC += valBCD & 0x0f;
  return(valDEC);
}

// reads the BCD at address on the RTC and returns a converted int value
// representing that piece of the date
int readTimeValue(int address){
  digitalWrite(CS, LOW);
  SPI.transfer(address);
  int valBCD = SPI.transfer(0x00);
  digitalWrite(CS, HIGH);
  int valDEC = convertBCDtoDEC(valBCD);
  return(valDEC);
}

// reads the entire yymmddhhmmss values from the RTC
void readTime(int * year,
              int * month,
              int * day,
              int * hour,
              int * minute,
              int * second){
  *year    = readTimeValue(0x06);
  *month   = readTimeValue(0x05);
  *day     = readTimeValue(0x04);
  *hour    = readTimeValue(0x02);
  *minute  = readTimeValue(0x01);
  *second  = readTimeValue(0x00);  
}


void placeDigitsInArray(char * datetime, int * index, int value){
  datetime[(*index)++] = (value / 10) + 0x30;
  datetime[(*index)++] = (value % 10) + 0x30; 
}

void constructDateString(char * datetime,
                         int year, 
                         int month, 
                         int day, 
                         int hour, 
                         int minute, 
                         int second){
  int i = 0;
  placeDigitsInArray(datetime, &i, year);
  datetime[i++] = '/';
  placeDigitsInArray(datetime, &i, month);
  datetime[i++] = '/';
  placeDigitsInArray(datetime, &i, day);
  datetime[i++] = ' ';
  placeDigitsInArray(datetime, &i, hour);
  datetime[i++] = ':';
  placeDigitsInArray(datetime, &i, minute);
  datetime[i++] = ':';
  placeDigitsInArray(datetime, &i, second);
  datetime[i++] = 0;  
}

void loop() {
  int year;
  int month;
  int day;
  int hour;
  int minute;
  int second;
  
  readTime(&year, &month, &day, &hour, &minute, &second);

  char datetime[18];
  constructDateString(datetime, year, month, day, hour, minute, second);
  Serial.write(datetime);  
  Serial.println();
  
  delay(1000);
}

