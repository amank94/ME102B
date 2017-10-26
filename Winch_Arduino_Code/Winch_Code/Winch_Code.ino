#include <SPI.h>

const int enc_A = 3;
const int enc_B = 4;
byte step_delta = 0; // 2 bytes, "short" range -2^15+1 to 2^15-1 (-32,767 to 32,767)
int enc_B_state;
volatile boolean process_it;
short junk; // dummy message from Master


void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(enc_A, INPUT_PULLUP); // interrupt-attached encoder channel
  pinMode(enc_B, INPUT_PULLUP); // normal input encoder channel
  attachInterrupt(digitalPinToInterrupt(3), count_steps, RISING); // attach interrupt to enc_A, detect rise
  pinMode(MISO, OUTPUT); // Master In *Slave Out*
  pinMode(MOSI, INPUT);
  SPCR |= _BV(SPE); // turn on SPI in slave mode
  SPCR |= _BV(SPIE); // turn on interrupts
  process_it = false;
  SPI.attachInterrupt();
}

ISR (SPI_STC_vect) {
  process_it = true;
}

void loop() {
  if (process_it) {
    junk = SPI.transfer16(8);
//  SPI.transfer(step_delta);  
    process_it = false;
//    step_delta = 0;
  }
}

void count_steps() {
  enc_B_state = digitalRead(enc_B); // when enc_A rises, check state of enc_B to determine direction
  if (enc_B_state == LOW) {
    step_delta++;
  }
  else {
    step_delta--;
  }
}
