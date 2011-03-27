void allOff() {
  digitalWrite(greenLED1, LOW);
  digitalWrite(greenLED2, LOW);
  digitalWrite(redLED1, LOW);
  digitalWrite(redLED2, LOW);
}

void allOn() {
  digitalWrite(greenLED1, HIGH);
  digitalWrite(greenLED2, HIGH);
  digitalWrite(redLED1, HIGH);
  digitalWrite(redLED2, HIGH);
}

void allRedOn() {
  digitalWrite(redLED1, HIGH);
  digitalWrite(redLED2, HIGH);
}

void allGreenOn() {
  digitalWrite(greenLED1, HIGH);
  digitalWrite(greenLED2, HIGH);
}
