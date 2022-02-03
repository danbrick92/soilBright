#include <SoftwareSerial.h>

SoftwareSerial BTSerial(11, 10); //RX, TX

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  BTSerial.begin(9600); // baud
  while (!Serial);
  Serial.println("AT commands: okay ");
  
}

void loop() {

  String line = "";
  // read from HM-10 and print in the Serial
  if (BTSerial.available()){
    Serial.write(BTSerial.read());
  }

  // read from the Serial and print to the HM-10
  if (Serial.available()){
    BTSerial.write(Serial.read());
  }
  
}
