int switchState = 0;


void setup() {
  // put your setup code here, to run once:
  pinMode(5, OUTPUT); // LED Ready
  pinMode(6, OUTPUT); // LED Measuring
  pinMode(7, OUTPUT); // LED Sent
  pinMode(4, INPUT); // Start Button
}

void loop() {
  // put your main code here, to run repeatedly:
  switchState = digitalRead(4);
  if (switchState == LOW) { 
    digitalWrite(5, HIGH);
    digitalWrite(6, LOW);
    digitalWrite(7, LOW);
  }
  else{
    digitalWrite(5, LOW);
    digitalWrite(6, HIGH);
    digitalWrite(7, HIGH);
  }
}
