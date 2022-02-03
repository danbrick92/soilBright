//-----------------------------------------------------------------------------------------------------
// Global area
//-----------------------------------------------------------------------------------------------------
// Sensor pins
#include <SoftwareSerial.h>
#include "HX711.h"

// const globals
const int READY_LED = 6;
const int MEASURE_LED = 7;
const int NO_MOISTURE = 620;
const int FULL_MOISTURE = 230;
const int CALIBRATION_MEASUREMENTS_MAX = 20;
SoftwareSerial Bluetooth(11, 10); //RX, TX
HX711 cell(3, 2);

// variable globals
float weight_of_object = 0.0;
String mode = "init";

// weight sensor calibration
float calibration_value = 0.0;
int calibration_count = 0;
float recorded_values = 0.0;
bool calibration_init = true;
float divisor_values = 0.0;

//-----------------------------------------------------------------------------------------------------
// Setup area
//-----------------------------------------------------------------------------------------------------
void setup() {
  // Start serial, components
  Serial.begin(9600);
  Serial.println("Initializing all components...");
  setup_leds();
  setup_bluetooth(); 
  // soil moisture & weight sensor need no init
  // at end of init, light up ready led
  change_mode("bluetooth_ready"); // CHANGE MEEEEEEEEEEEEEEEEEEEEE
  Serial.println("Switched to mode " + mode);
}

void setup_leds() { 
  //initialize LEDs
  pinMode(READY_LED, OUTPUT);
  pinMode(MEASURE_LED, OUTPUT);
}

void setup_bluetooth() { 
  // initialize bluetooth
  Bluetooth.begin(9600); // baud
  while (!Serial);
  Serial.println("AT commands: okay ");
}

//-----------------------------------------------------------------------------------------------------
// Loop area
//-----------------------------------------------------------------------------------------------------
void loop() {
  // put your main code here, to run repeatedly:
  if (mode == "bluetooth_ready") { 
    digitalWrite(READY_LED, HIGH);
    digitalWrite(MEASURE_LED, LOW);
    bool retval = waiting_iphone("bluetooth_ready");
    if (retval == true) {
      change_mode("calibration_init");
      send_message_iphone("connected");
      calibration_init = true;
    }
  }
  else if (mode == "calibration_init") { 
    digitalWrite(READY_LED, LOW);
    digitalWrite(MEASURE_LED, HIGH);
    set_calibration();
    if (calibration_init == false){
      change_mode("calibration_ready");
    }
  }
  else if (mode == "calibration_ready") { 
    digitalWrite(READY_LED, HIGH);
    digitalWrite(MEASURE_LED, LOW);
    String calibration_value_string = await_message_iphone();
    if (calibration_value_string == "reset" or calibration_value_string == "bluetooth_ready") { 
      mode = "reset";
    }
    else if (calibration_value_string != "") {
      calibration_value = calibration_value_string.toFloat();
      change_mode("calibrating");
      calibration_count = 0;
    }
  }
  else if (mode == "calibrating") { 
    digitalWrite(READY_LED, LOW);
    digitalWrite(MEASURE_LED, HIGH);
    bool complete = set_calibration_val();
    if (complete == true) {
      Serial.println((cell.read() - recorded_values) * divisor_values );
      send_message_iphone("ready_for_weight");
      change_mode("weight_ready");
      digitalWrite(MEASURE_LED, LOW);
      digitalWrite(READY_LED, HIGH);
    }
  }
  else if (mode == "weight_ready") { 
    digitalWrite(READY_LED, HIGH);
    digitalWrite(MEASURE_LED, LOW);
    bool retval = waiting_iphone("weight_ready");
    if (retval == true) {
      change_mode("weighing");
      calibration_count = 0;
    }
  }
  else if (mode == "weighing") { 
    digitalWrite(READY_LED, LOW);
    digitalWrite(MEASURE_LED, HIGH);
    bool weighed = false;
    weighed = weigh_item();
    if (weighed == true) {
      send_message_iphone(String(weight_of_object));
      change_mode("moisture_ready");
    }
  }
  else if (mode == "moisture_ready") { 
    digitalWrite(READY_LED, HIGH);
    digitalWrite(MEASURE_LED, LOW);
    bool retval = waiting_iphone("moisture_ready");
    if (retval == true) {
      change_mode("moisture_measuring");
    }
  }
  else if (mode == "moisture_measuring") { 
    digitalWrite(READY_LED, LOW);
    digitalWrite(MEASURE_LED, HIGH);
    int moisture = measure_moisture();
    send_message_iphone(String(moisture));
    Serial.println("Completed sensor cycle. Resetting to bluetooth_ready.");
    change_mode("bluetooth_ready");
  }
  else if (mode == "reset") { 
    Serial.println("Received reset signal. Resetting to bluetooth_ready.");
    weight_of_object = 0.0;
    // reset values
    calibration_value = 0.0;
    calibration_count = 0;
    recorded_values = 0.0;
    calibration_init = true;
    divisor_values = 0.0;
    change_mode("bluetooth_ready");
  }
  else{
    Serial.println("Received unknown signal. Resetting to bluetooth_ready.");
    change_mode("bluetooth_ready");
  }
}

// calibrates the weight sensor offset for the current run
void set_calibration() { 
  if (calibration_count < CALIBRATION_MEASUREMENTS_MAX) { 
    recorded_values = recorded_values + cell.read();
  }
  if (calibration_count == CALIBRATION_MEASUREMENTS_MAX) { 
    recorded_values =  recorded_values / (CALIBRATION_MEASUREMENTS_MAX * 1.0);
    calibration_init = false;
    Serial.println("Calibration offset: " + String(recorded_values));
  }
  calibration_count ++; 
}

// calibrates the weight sensor divisor for the current run
bool set_calibration_val(){ 
  bool retval = false;
  if (calibration_count < CALIBRATION_MEASUREMENTS_MAX)
  {
    divisor_values += cell.read();
  }
  else if (calibration_count == CALIBRATION_MEASUREMENTS_MAX)
  {
    divisor_values = (divisor_values / (CALIBRATION_MEASUREMENTS_MAX * 1.0)) - recorded_values;
    divisor_values = calibration_value / divisor_values;
    Serial.println("Calibration multiplier: " + String(divisor_values));
    retval = true;
  }
  calibration_count++;
  return retval; 
}

// weighs the item on the scale
bool weigh_item(){
  bool retval = false;
  if (calibration_count < CALIBRATION_MEASUREMENTS_MAX)
  {
    weight_of_object += (cell.read() - recorded_values) * divisor_values;
  }
  else if (calibration_count == CALIBRATION_MEASUREMENTS_MAX)
  {
    weight_of_object = (weight_of_object / (CALIBRATION_MEASUREMENTS_MAX * 1.0));
    retval = true;
    Serial.println("Object weight: " + String(weight_of_object));
  }
  calibration_count++;
  return retval;
}

// measures the moisture of the soil
int measure_moisture(){ 
  int soil_moist_val = analogRead(A0);
  int soil_moist_percent = map(soil_moist_val, NO_MOISTURE, FULL_MOISTURE, 0, 100);
  Serial.println("Soil moisture: " + soil_moist_percent);
  return soil_moist_percent;
}

// waits for the iphone to send back an expected message
bool waiting_iphone(String expected) { 
  
  bool retval = false;
  String message = await_message_iphone();
  if (message == "reset") { 
      change_mode("reset");
  }
  else{ 
    retval = meets_message_expectations(message, expected);
  }
  return retval;
}

// Waits to receieve a message from the iPhone in terms of 
String await_message_iphone() { 
  String retval = "";
  delay(100);
  if(Bluetooth.available()){
    retval = Bluetooth.readString();
  }
  return retval;
}

// Send message to the iPhone
void send_message_iphone(String message) { 
  for (int i = 0; i < message.length(); i++)
  {
    Bluetooth.write(message[i]);   // Push each char 1 by 1 on each loop pass
  }
}

// Validates that the message received is the one expected by the iPhone
bool meets_message_expectations(String message_received, String message_expected) { 
  bool meets_expectations = false;
  if (message_received == message_expected) { 
    meets_expectations = true;
  }
  return meets_expectations;
}

// Changes the loop mode
void change_mode(String new_mode){
  Serial.println("Switching to mode " + new_mode);
  mode = new_mode;
}
