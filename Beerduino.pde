/*
Very early rough draft sketch for Beerduino

Goal of this project is to regulate temperature in a
refridgerator by controlling the compressor and a 
separate heating element according to readings from
temperature sensors. Unit will take commands over serial
from a computer and will answer queries. The ultimate
intent is to log this information onto a Rails site and
make system fully available remotely via the web.

Malcolm Morris-Pence 2011
*/

#include <OneWire.h>
#include <DallasTemperature.h>
#include <LiquidCrystal.h>

// Target temperature:
float targetTemp = 70.00;
int readInterval = 2000;

// Declaring some variables
float currentAnalogTemp = 0.0;
float currentDigitalTemp1 = 0.0;
float currentDigitalTemp2 = 0.0;
unsigned long timeNow;
unsigned long lastTempCheck;
unsigned long lastLEDCheck;

boolean compressorState = false;
boolean heaterState = false;


// LED Setup
int greenLED1 = 9;
int greenLED2 = 10;
int redLED1 = 8;
int redLED2 = 7;

// LCD Setup
LiquidCrystal lcd(13, 12, 5, 4, 3, 2);
// Define backlight pin if used:
// int backLight = 13;

// Make the degree character
byte degreeChar[8] = {
	B01100,
	B10010,
	B10010,
	B01100,
	B00000,
	B00000,
	B00000,
	B00000
};

// Digital temperature sensor setup
#define ONE_WIRE_BUS 6
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);
DeviceAddress digitalThermometer1 = { 0x28, 0xDD, 0xAD, 0xE3, 0x02, 0x00, 0x00, 0xC1 };
DeviceAddress digitalThermometer2 = { 0x28, 0xC4, 0xA2, 0xE3, 0x02, 0x00, 0x00, 0x63 };

void setup(void) {
  Serial.begin(9600);
  
  // LED pins
  pinMode(greenLED1, OUTPUT);
  pinMode(greenLED2, OUTPUT);
  pinMode(redLED1, OUTPUT);
  pinMode(redLED2, OUTPUT);
  
  // Initialize digital sensors
  sensors.begin();
  sensors.setResolution(digitalThermometer1, 10);
  sensors.setResolution(digitalThermometer2, 10);
  
  // LCD Screen
  lcd.createChar(0, degreeChar); // create degree character
  // pinMode(backLight, OUTPUT);
  // digitalWrite(backLight, HIGH); // turn backlight on. Replace 'HIGH' with 'LOW' to turn it off.
  lcd.begin(20,4);              // columns, rows.  use 16,2 for a 16x2 LCD, etc.
  lcd.clear();                  // start with a blank screen
  lcd.setCursor(3,0);           // set cursor to column 0, row 0 (the first row)
  lcd.print("--Beerduino!--");    // change this text to whatever you like. keep it clean.
  lcd.setCursor(0,1);           // set cursor to column 0, row 1
  lcd.print("Target Temp:  ");
  lcd.print(targetTemp);
  lcd.write(0);
  lcd.setCursor(0,2);         // set cursor to column 0, row 2
  lcd.print("Aquiring temperature");
  lcd.setCursor(2,3);         // set cursor to column 0, row 3
  lcd.print("Status goes here");
}
    
void checkTemp() {
  timeNow = millis();
  if (timeNow >= lastTempCheck + readInterval) {
   currentAnalogTemp = analogTemp();
   printAnalogTemp();
   
   sensors.requestTemperatures();
   currentDigitalTemp1 = digitalTemp(digitalThermometer1);
   currentDigitalTemp2 = digitalTemp(digitalThermometer2);
   
   transmitDigitalTemp(1);
   transmitDigitalTemp(2);
   Serial.print("---\n");
   
   // Update clock
   lastTempCheck = timeNow;
  }
}

void checkLEDs() {
 timeNow = millis();
 if (timeNow >= lastLEDCheck + readInterval + 20) { // 20ms offset from checkTemp
  
  if (currentAnalogTemp >= 
    // Light up greens if hot
  if (currentAnalogTemp > targetTemp + 1) {
    if (compressorState == 0) {
      clearLCDRow(3);
      lcd.setCursor(0,3);
      lcd.print("Compressor is on");
      // Actually turn on compressor here
      compressorState = 1;
    }
    digitalWrite(greenLED1, HIGH);
    if (currentAnalogTemp > targetTemp + 3) {
      digitalWrite(greenLED2, HIGH);
    }
  }
  
  // Light up reds if cold
  if (currentAnalogTemp < targetTemp) {
    if (heaterState == 0) {
      clearLCDRow(3);
      lcd.setCursor(0,3);
      lcd.print("Heater is on");
      // Actually turn on heater here
      heaterState = 1;
    }
    digitalWrite(redLED1, HIGH);
    if (currentAnalogTemp < targetTemp - 2) {
      digitalWrite(redLED2, HIGH);
    }
  }
  
  lastLEDCheck = timeNow;
 } 
}

// Main loop function
void loop(void) {
  allOff();
  
  checkTemp();
  
  checkLEDs();
  

  
  // delay(3000);
}

