const int step_pins[] = {4, 5, 6, 7}; // pins used to send step command to stepper drivers
const int dir_pins[] = {8, 9, 10, 11}; // pins used to send direction command to stepper drivers

unsigned long previous_micros; // store previous timestamp (microseconds)
unsigned long current_micros; // store current timestamp (microseconds)
const int time_step = 100; // time step of path generation script (microseconds)

int cmd[][8] = {{1, -1, 1, -1, 1, -1, 1, -1},
            {1, 1, 1, 1, -1, -1, -1, -1},
            {-1, -1, 0, 0, 1, 1, 0, 0},
            {1, 0, -1, 0, 1, 0, -1, 0}}; // temporary "command" array to sub in for MATLAB-generated one
            // rows are for each stepper, columns correspond to each time step
            // 1: take step with forward direction
            // -1: take step with reverse direction
            // 0: do nothing


void setup() {
  for (int p = 0; p < 4; p++) {
    pinMode(step_pins[p], OUTPUT);
    pinMode(dir_pins[p], OUTPUT);
    digitalWrite(step_pins[p], LOW);
    digitalWrite(dir_pins[p], LOW); // iterate through step and dir pins, setting as output and writing low
  }
  
  previous_micros = micros(); // inititalize previous time before beginning loop
}

void loop() {
  for (int i = 0; i < 8 ; i++) { // iterate through each time step in cmd
    for (int j = 0; j < 4; j++) { // iterate through each stepper motor's commands within each time step
      switch (cmd[j][i]) {
        case 1: // if 1, set direction forward (high) and send quick high pulse to step pin
          digitalWrite(dir_pins[j], HIGH);
          digitalWrite(step_pins[j], HIGH);
          digitalWrite(step_pins[j], LOW);
          break;
        case -1: // if -1, set direction reverse (low) and send quick high pulse to step pin
          digitalWrite(dir_pins[j], LOW);
          digitalWrite(step_pins[j], HIGH);
          digitalWrite(step_pins[j], LOW);
          break;
        default: // if 0, keep step pin low. probably unnecessary
          digitalWrite(step_pins[j], LOW);
          break;
      }
    }

    current_micros = micros(); // grab current timestamp
    if ((current_micros - previous_micros) < (time_step)) { // compare time difference, subtract measured error
      delayMicroseconds(time_step-(current_micros-previous_micros)); // delay a tiny bit if not enough time has passed
    }
    previous_micros = micros(); // grab current timestamp for comparison in the next iteration
  }

}
