void printLCDTemp(float tempToDisplay) {
  lcd.setCursor(0,2);
  lcd.print("Current Temp: ");
  lcd.print(tempToDisplay);
  lcd.write(0);
}

void clearLCDRow(int row) {
  lcd.setCursor(0, row);
  lcd.print("                    ");
}

void printAnalogTemp() {
  lcd.setCursor(0,2);
  lcd.print("Current Temp: ");
  lcd.print(currentAnalogTemp);
  lcd.write(0);
}

void printDigitalTemp1() {
  lcd.setCursor(0,2);
  lcd.print("Digital 1:    ");
  lcd.print(currentDigitalTemp1);
  lcd.write(0);
}

void printDigitalTemp2() {
  lcd.setCursor(0,2);
  lcd.print("Digital 2:    ");
  lcd.print(currentDigitalTemp1);
  lcd.write(0);
}
