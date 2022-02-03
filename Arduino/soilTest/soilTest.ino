const int airValue = 620;
const int waterValue = 230;
int soilMoistureValue = 0;
int soilMoisturePercent = 0;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  soilMoistureValue = analogRead(A0);
  //Serial.println(soilMoistureValue);
  soilMoisturePercent = map(soilMoistureValue, airValue, waterValue, 0, 100);
  Serial.println(soilMoisturePercent);
}
