#include <HX711_ADC.h>

HX711_ADC loadCell(4 ,5);

void setup() {
  // put your setup code here, to run once:
  loadCell.begin();
  loadCell.start(2000);
  loadCell.setCalFactor(1.0);
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  loadCell.update();
  float i = loadCell.getData();
  Serial.println( i);
}
