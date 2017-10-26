#include <SPI.h>

const int enc_A = 3;
const int enc_B = 4;
const int trigger = 2;
long step_delta = 0;
int enc_B_state;
int deg_delta;


void setup() {
  pinMode(enc_A, INPUT_PULLUP);
  pinMode(enc_B, INPUT_PULLUP);
  pinMode(trigger, INPUT_PULLUP);
  //  pinMode(SPI_SS, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(3), count_steps, RISING);
  attachInterrupt(digitalPinToInterrupt(2), send_data, RISING);
  Serial.begin(9600);

}

void loop() {
  while (Serial.available() > 0) {
    if (Serial.read() == '?') {
      deg_delta = step_delta*0.6;
      Serial.println(deg_delta);
      step_delta = 0;
    }
  }
}

void count_steps() {
  enc_B_state = digitalRead(enc_B);
  if (enc_B_state == LOW) {
    step_delta++;
  }
  else {
    step_delta--;
  }
}

void send_data() {
  deg_delta = step_delta*0.6;
  Serial.println(deg_delta);
  step_delta = 0;
}

 

