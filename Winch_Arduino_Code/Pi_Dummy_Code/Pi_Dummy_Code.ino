#include <SPI.h>
short response; // incoming data from Slave

void setup() {
  Serial.begin(9600);
  pinMode(SS, OUTPUT);
  pinMode(MISO, INPUT);
  pinMode(MOSI, OUTPUT);
  SPI.begin();
}

void loop() {
  while(Serial.available() > 0) {
    if (Serial.read() == '?') {
      SPI.beginTransaction(SPISettings(1200000, MSBFIRST, SPI_MODE0));
      digitalWrite(SS, LOW);
      response = SPI.transfer16(32);
      digitalWrite(SS, HIGH);
      SPI.endTransaction();
      Serial.println(response);
    }
  }
}
