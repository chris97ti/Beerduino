void printLCDTemp() {
  lcd.setCursor(0,2);
  lcd.print("Current Temp: ");
  lcd.print(currentAnalogTemp);
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
