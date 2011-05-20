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
float tempDifferential = 1.5; // how many degrees +/- to stray from target temp before turning on
int readInterval = 2000; // read every 2 seconds
long applianceDelay = 120000; // how long between turning of a device and turning on again


// Declaring some variables
float currentAnalogTemp = 0.0;
float currentDigitalTemp1 = 0.0;
float currentDigitalTemp2 = 0.0;
unsigned long timeNow;
unsigned long lastTempCheck;
unsigned long lastLEDCheck;

int lastDisplayedTemp = 0; // which sensor's temp was last displayed
unsigned long lastTempRotation; // time when the current displayed temp started to show
int tempRotationInterval = 4; //interval to rotate temperatures
unsigned long timeOfLastOff;

boolean compressorState = false;
boolean heaterState = false;


// LED Setup
int greenLED = 8;
int redLED = 7;

// Relay Setup
int compressorRelay = 11;
int heaterRelay = 10;

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
DeviceAddress digitalThermometer1 = { 
  0x28, 0xDD, 0xAD, 0xE3, 0x02, 0x00, 0x00, 0xC1 };
DeviceAddress digitalThermometer2 = { 
  0x28, 0xC4, 0xA2, 0xE3, 0x02, 0x00, 0x00, 0x63 };

void setup(void) {
  Serial.begin(9600);

  // LED pins
  pinMode(greenLED, OUTPUT);
  pinMode(redLED, OUTPUT);
  
  // Relay pins
  pinMode(compressorRelay, OUTPUT);
  pinMode(heaterRelay, OUTPUT);

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
    //printLCDTemp(currentAnalogTemp);

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

// Display temps on 3rd line, rotating at specified interval
void showTemps(int interval) {
  timeNow = millis();
  
  if (timeNow >= lastTempRotation + interval * 1000) {
    if (lastDisplayedTemp == 0) {
      printDigitalTemp1();
    }
    else if (lastDisplayedTemp == 1) {
      printDigitalTemp2();
    }
    else {
      printAnalogTemp();
    }
    
    if (lastDisplayedTemp <= 1) {
      lastDisplayedTemp++;
    }
    else {
      lastDisplayedTemp = 0;
    }
    
    lastTempRotation = timeNow;
    
  }
}

void checkLEDs() {
  timeNow = millis();
  if (timeNow >= lastLEDCheck + readInterval + 20) { // 20ms offset from checkTemp
    allOff();

    if (currentAnalogTemp <= targetTemp + 1 && currentAnalogTemp <= targetTemp) {
      compressorState = 0;
      heaterState = 0;
      clearLCDRow(3);
      lcd.setCursor(0,3);
      lcd.print("Temp is kosher!");
    }

    // Light up greens if hot
    if (currentAnalogTemp > targetTemp + tempDifferential) {
      if (compressorState == 0) {
        clearLCDRow(3);
        lcd.setCursor(0,3);
        lcd.print("Compressor is on");
        // Actually turn on compressor here
        compressorState = 1;
        heaterState = 0; // Just in case
      }
      digitalWrite(greenLED, HIGH);
    }

    // Light up reds if cold
    if (currentAnalogTemp < targetTemp - tempDifferential) {
      if (heaterState == 0) {
        clearLCDRow(3);
        lcd.setCursor(0,3);
        lcd.print("Heater is on");
        // Actually turn on heater here
        heaterState = 1;
        compressorState = 0; // Just in case
      }
      digitalWrite(redLED, HIGH);
    }

    lastLEDCheck = timeNow;
  } 
}

// Main loop function
void loop(void) {
  checkTemp();

  checkLEDs();

  showTemps(tempRotationInterval);
}


