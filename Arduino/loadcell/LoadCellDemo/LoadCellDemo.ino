#include "HX711.h"

HX711 cell(3, 2);
bool calibration = true;
int measurements_max = 10;
int measured = 0;
float calibration_val = 0.0;

void setup() {
  Serial.begin(9600);
}

long val = 0;
float count = 0;

void loop() {
  float cval = get_calibration_val();
  float known_val = get_known_val();
  //count = count + 1;
  
  // Use only one of these
  //val = ((count-1)/count) * val    +  (1/count) * cell.read(); // take long term average
  val = 0.5 * val    +   0.5 * cell.read(); // take recent average
  
  val = cell.read(); // most recent reading
  Serial.println( (val - cval) / 315.00f  );
  //if (calibration_val > 0){
  ////  Serial.println( (val - calibration_val)  );
  //}
  //else {
  //  Serial.println( (val + calibration_val)  );
  //}
  
}

float get_calibration_val() { 
  if (calibration) { 
    if (measured < measurements_max) { 
      calibration_val = calibration_val + cell.read();
      //Serial.println( cell.read());
    }
    if (measured == measurements_max) { 
      calibration = false;
      calibration_val =  calibration_val / (measurements_max * 1.0);
      //Serial.println( calibration_val );
      Serial.println( cell.read() - calibration_val);
    }
    measured ++; 
  }
  return calibration_val;
}

float get_known_val() { 
  float known_val = 169.00;
  return known_val;
}
