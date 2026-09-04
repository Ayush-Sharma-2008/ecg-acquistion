const uint8_t PIN_ECG      = A0;
const uint8_t PIN_LO_PLUS  = 11;
const uint8_t PIN_LO_MINUS = 10;

const unsigned long SAMPLE_PERIOD_US = 2000UL;   // 2000 us -> 500 Hz
unsigned long nextSample = 0;

void setup() {
  Serial.begin(250000);
  pinMode(PIN_LO_PLUS,  INPUT);
  pinMode(PIN_LO_MINUS, INPUT);
  Serial.println(F("t_us,adc,leadsoff"));
  nextSample = micros();
}

void loop() {
  if ((long)(micros() - nextSample) >= 0) {
    nextSample += SAMPLE_PERIOD_US;
    uint8_t off = (digitalRead(PIN_LO_PLUS) || digitalRead(PIN_LO_MINUS)) ? 1 : 0;
    int adc = off ? -1 : analogRead(PIN_ECG);
    Serial.print(micros());
    Serial.print(',');
    Serial.print(adc);
    Serial.print(',');
    Serial.println(off);
  }
}