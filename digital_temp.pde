// Primary function for reading digital temp sensors 

void printDigitalTemp(DeviceAddress deviceAddress){
  float tempC = sensors.getTempC(deviceAddress);
  if (tempC == -127.00) {
    Serial.print("Error getting temperature");
  } else {
    Serial.print("C: ");
    Serial.print(176, BYTE);
    Serial.print(tempC);
    Serial.print(" F: ");
    Serial.print(DallasTemperature::toFahrenheit(tempC));
    Serial.print(176, BYTE);
  }
}


float digitalTemp(DeviceAddress deviceAddress) {
  float fTemp;
  float tempC = sensors.getTempC(deviceAddress);
  fTemp = (tempC * 1.8) + 32.0;
  return fTemp;
}

void transmitDigitalTemp(int sensorNumber) {
  Serial.print("D Temp");
  Serial.print(sensorNumber);
  Serial.print(": ");
  
  // Sloppy, need to make something cleaner:
  if (sensorNumber == 1) {
    Serial.print(currentDigitalTemp1);
  }
  if (sensorNumber == 2) {
    Serial.print(currentDigitalTemp2);
  }
  Serial.print("\n");
}
