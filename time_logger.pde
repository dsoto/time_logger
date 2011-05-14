#include <SPI.h>

unsigned int val;
unsigned int digit;
const int CS = 10;  // chip select pin


void setup() {
   
   // wait a bit for the openlog to boot up
   delay(5000);
   
   // initialize the serial port
   // communication between the arduino and the open log is over serial
   Serial.begin(9600);
   
   // initialize the SPI communication
   // communication between the arduino and the real time clock is over SPI
   SPI.begin();
   SPI.setBitOrder(MSBFIRST);
   SPI.setDataMode(SPI_MODE3);
   pinMode(10, OUTPUT);

   // this should be the first line of file
   Serial.println("Begin Date Logger");
}

// this function encapsulates a write to the real time clock
void writeToSPI(int instruction, int value){
  digitalWrite(CS, LOW);
  SPI.transfer(instruction);
  SPI.transfer(value);
  digitalWrite(CS, HIGH);
}

// this function takes a string on the serial port ond sets the 
// real time clock accordingly.
// it is verbose to preserve clarity.
void setTime(String response){
  // year
  val = 0;
  int i = 0;
  digit = response.charAt(i++) - 0x30;
  val |= digit << 4;
  digit = response.charAt(i++) - 0x30;
  val |= digit;
  writeToSPI(0x86, val);

  // month
  val = 0;
  digit = response.charAt(i++) - 0x30;
  val |= digit << 4;
  digit = response.charAt(i++) - 0x30;
  val |= digit;
  writeToSPI(0x85, val);

  // day
  val = 0;
  digit = response.charAt(i++) - 0x30;
  val |= digit << 4;
  digit = response.charAt(i++) - 0x30;
  val |= digit;
  writeToSPI(0x84, val);

  // hour
  val = 0;
  digit = response.charAt(i++) - 0x30;
  val |= digit << 4;
  digit = response.charAt(i++) - 0x30;
  val |= digit;
  writeToSPI(0x82, val);

  // minute
  val = 0;
  digit = response.charAt(i++) - 0x30;
  val |= digit << 4;
  digit = response.charAt(i++) - 0x30;
  val |= digit;
  writeToSPI(0x81, val);

  // seconds
  val = 0;
  digit = response.charAt(i++) - 0x30;
  val |= digit << 4;
  digit = response.charAt(i++) - 0x30;
  val |= digit;
  writeToSPI(0x80, val);
}

// this function writes the time from the real time clock into a string
String readTimeToString(){
  String time = "";

  // year
  digitalWrite(10, LOW);
  SPI.transfer(0x06);
  val = SPI.transfer(0x00);
  digitalWrite(10, HIGH);
  digit = (val & 0xF0) >> 4;
  time.concat(digit);
  digit = (val & 0x0F);
  time.concat(digit);
  time.concat('/');

  // month
  digitalWrite(10, LOW);
  SPI.transfer(0x05);
  val = SPI.transfer(0x00);
  digitalWrite(10, HIGH);
  digit = (val & 0xF0) >> 4;
  time.concat(digit);
  digit = (val & 0x0F);
  time.concat(digit);
  time.concat('/');

  // day
  digitalWrite(10, LOW);
  SPI.transfer(0x04);
  val = SPI.transfer(0x00);
  digitalWrite(10, HIGH);
  digit = (val & 0xF0) >> 4;
  time.concat(digit);
  digit = (val & 0x0F);
  time.concat(digit);
  time.concat(" ");

  // hour
  digitalWrite(10, LOW);
  SPI.transfer(0x02);
  val = SPI.transfer(0x00);
  digitalWrite(10, HIGH);
  digit = (val & 0x30) >> 4;
  time.concat(digit);
  digit = (val & 0x0F);
  time.concat(digit);
  time.concat(":");

  // minute
  digitalWrite(10, LOW);
  SPI.transfer(0x01);
  val = SPI.transfer(0x00);
  digitalWrite(10, HIGH);
  digit = (val & 0xF0) >> 4;
  time.concat(digit);
  digit = (val & 0x0F);
  time.concat(digit);
  time.concat(":");

  
  // seconds
  digitalWrite(10, LOW);
  SPI.transfer(0x00);
  val = SPI.transfer(0x00);
  digitalWrite(10, HIGH);
  digit = (val & 0xF0) >> 4;
  time.concat(digit);
  digit = (val & 0x0F);
  time.concat(digit);
  

  return(time);
}

void loop() {

  String time = readTimeToString();
  // if time minutes is multiple of 5 and seconds equal zero
  if (1) {
    int minutesOnes = time.charAt(13) - 0x30;
    int secondsTens = time.charAt(15) - 0x30;
    int secondsOnes = time.charAt(16) - 0x30;
    if ((minutesOnes % 5 == 0) && (secondsTens == 0) && (secondsOnes == 0)){
    Serial.println(time);
    }
  }

  // chill
  delay(1000);

  // poll for serial input
  // if serial input available, set clock accordingly
  String response = "";
  while (Serial.available() > 0) {
    response.concat(char(Serial.read()));
  }
  if (response != ""){
    Serial.println(response);
    setTime(response);
  }
}

