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

// value is written to datetime string in two digits and the string address index is incremented
void placeDigitsInArray(char * datetime, int * index, int value){
  datetime[(*index)++] = (value / 10) + 0x30;
  datetime[(*index)++] = (value % 10) + 0x30;
}

// using the values passed in, an 18 digit zero terminated string is constructed and passed back
char * constructDateString(int year,
                           int month,
                           int day,
                           int hour,
                           int minute,
                           int second){
  char datetime[18];
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
  return(datetime);
}

void loop() {
  int year;
  int month;
  int day;
  int hour;
  int minute;
  int second;

  readTime(&year, &month, &day, &hour, &minute, &second);
  char * datetime = constructDateString(year, month, day, hour, minute, second);
  Serial.write(datetime);
  Serial.println();

  delay(1000);

  // todo read input into serial string and write RTC with value
  // read string
  // create BCD for each
  // write BCD to registers

  char dateString[13];
  if (Serial.available() >= 12){
    for (int i=0; i<12; i++){
      dateString[i] = Serial.read();
    }
    dateString[12] = 0;
    Serial.print("received string ");
    Serial.write(dateString);
    Serial.println();

  int i = 0;
  int val = 0;
  int digit = 0;

  // year
  val = 0;
  val |= (dateString[i++] - 0x30) << 4;
  val |= (dateString[i++] - 0x30);
  writeToSPI(0x86, val);

  // month
  val = 0;
  val |= (dateString[i++] - 0x30) << 4;
  val |= (dateString[i++] - 0x30);
  writeToSPI(0x85, val);

  // day
  val = 0;
  digit = dateString[i++] - 0x30;
  val |= digit << 4;
  digit = dateString[i++] - 0x30;
  val |= digit;
  writeToSPI(0x84, val);

  // hour
  val = 0;
  digit = dateString[i++] - 0x30;
  val |= digit << 4;
  digit = dateString[i++] - 0x30;
  val |= digit;
  writeToSPI(0x82, val);

  // minute
  val = 0;
  digit = dateString[i++] - 0x30;
  val |= digit << 4;
  digit = dateString[i++] - 0x30;
  val |= digit;
  writeToSPI(0x81, val);

  // seconds
  val = 0;
  digit = dateString[i++] - 0x30;
  val |= digit << 4;
  digit = dateString[i++] - 0x30;
  val |= digit;
  writeToSPI(0x80, val);

  }


}

