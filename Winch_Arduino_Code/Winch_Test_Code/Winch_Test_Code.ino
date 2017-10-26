#include <Stepper.h>

int revs = 0;
int steps = 0;
const int stepPin = 5;
const int dirPin = 6;
const int stepsPerRev = 200;

void setup() {
  Serial.begin(9600);
  

}

void loop() {
  while(Serial.available() > 0) {
    revs = Serial.parseInt();
    if(revs > 0) {
      digitalWrite(dirPin, HIGH);
    }
    else {
      digitalWrite(dirPin, LOW);
    }
    steps = (stepsPerRev*revs)/10;
    for(int x = 0; x < steps; x++) {
      digitalWrite(stepPin, HIGH);
      digitalWrite(stepPin, LOW);
      delay(3);
//      Serial.println(x);
    }
  }
}
