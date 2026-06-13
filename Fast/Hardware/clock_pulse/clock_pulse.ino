#define CLOCK 2

#define WAIT 1

void setup() {
  // put your setup code here, to run once:
  pinMode(CLOCK, OUTPUT);
  Serial.begin(57600);
}

void loop() {
  // put your main code here, to run repeatedly:
  delay(WAIT);
  digitalWrite(CLOCK,0); 
  delay(WAIT);
  digitalWrite(CLOCK,1);
}

void waitForSerial(){
  while (!Serial.available()) {
  }
  Serial.println(Serial.read());
}
