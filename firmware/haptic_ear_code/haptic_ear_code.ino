// ================= PIN DEFINITIONS =================
const int leftMicPin  = 34;
const int rightMicPin = 35;

const int leftMotorPin  = 25;
const int rightMotorPin = 27;

// ================= PWM SETTINGS ====================
const int pwmFreq = 2000;
const int pwmResolution = 8; // 0–255

// ================= AUDIO PARAMETERS =================
const float alphaSignal = 0.30;   // fast smoothing
const float alphaNoise  = 0.01;   // slow noise-floor tracking

const int activationMargin = 140; // how far above noise = real sound
const int directionTolerance = 90;

// False-trigger suppression
const int confirmCountRequired = 4;   // must persist
const int minEffectiveEnergy   = 170; // strong gate
const int minOnTimeMs          = 120; // no flicker

// Motor tuning
const int minPWM = 90;
const int maxPWM = 220;

// ================= STATE ===========================
float leftSignal  = 0;
float rightSignal = 0;

float leftNoise   = 0;
float rightNoise  = 0;

int leftBias  = 0;
int rightBias = 0;

int leftConfirm  = 0;
int rightConfirm = 0;

unsigned long lastOnTime = 0;

// ================= SETUP ===========================
void setup() {
  Serial.begin(115200);

  analogReadResolution(12);
  analogSetAttenuation(ADC_11db);

  pinMode(leftMotorPin, OUTPUT);
  pinMode(rightMotorPin, OUTPUT);
  digitalWrite(leftMotorPin, LOW);
  digitalWrite(rightMotorPin, LOW);

  ledcAttach(leftMotorPin, pwmFreq, pwmResolution);
  ledcAttach(rightMotorPin, pwmFreq, pwmResolution);

  delay(1000); // allow MAX9814 AGC to settle

  leftBias  = measureBias(leftMicPin);
  rightBias = measureBias(rightMicPin);

  Serial.print("Left bias: ");
  Serial.println(leftBias);
  Serial.print("Right bias: ");
  Serial.println(rightBias);

  Serial.println("System ready.");
}

// ================= BIAS MEASURE ====================
int measureBias(int pin) {
  long sum = 0;
  for (int i = 0; i < 200; i++) {
    sum += analogRead(pin);
    delay(2);
  }
  return sum / 200;
}

// ================= PEAK READ =======================
int readPeak(int pin, int bias) {
  int peak = 0;
  unsigned long t0 = millis();

  while (millis() - t0 < 10) {
    int v = analogRead(pin);
    int delta = abs(v - bias);
    if (delta > peak) peak = delta;
  }
  return peak;
}

// ================= MAIN LOOP =======================
void loop() {

  // ---- RAW PEAKS ----
  int leftPeak  = readPeak(leftMicPin, leftBias);
  int rightPeak = readPeak(rightMicPin, rightBias);

  // ---- FAST SIGNAL SMOOTHING ----
  leftSignal  = alphaSignal * leftPeak  + (1 - alphaSignal) * leftSignal;
  rightSignal = alphaSignal * rightPeak + (1 - alphaSignal) * rightSignal;

  // ---- SLOW NOISE FLOOR ----
  leftNoise  = alphaNoise * leftSignal  + (1 - alphaNoise) * leftNoise;
  rightNoise = alphaNoise * rightSignal + (1 - alphaNoise) * rightNoise;

  // ---- EFFECTIVE ENERGY ----
  int leftEffective  = leftSignal  - leftNoise;
  int rightEffective = rightSignal - rightNoise;

  if (leftEffective < 0)  leftEffective = 0;
  if (rightEffective < 0) rightEffective = 0;

  // ---- TEMPORAL CONFIRMATION ----
  if (leftEffective  > minEffectiveEnergy) leftConfirm++;
  else leftConfirm = 0;

  if (rightEffective > minEffectiveEnergy) rightConfirm++;
  else rightConfirm = 0;

  bool leftActive  = leftConfirm  >= confirmCountRequired;
  bool rightActive = rightConfirm >= confirmCountRequired;

  int leftPWM = 0;
  int rightPWM = 0;

  if (leftActive || rightActive) {

    int diff = leftEffective - rightEffective;

    // CENTER (front horn)
    if (abs(diff) <= directionTolerance) {
      int strength = max(leftEffective, rightEffective);
      int pwm = map(strength,
                    activationMargin, 900,
                    minPWM, maxPWM);
      pwm = constrain(pwm, minPWM, maxPWM);
      leftPWM = pwm;
      rightPWM = pwm;
    }

    // LEFT
    else if (diff > directionTolerance && leftActive) {
      leftPWM = map(leftEffective,
                    activationMargin, 900,
                    minPWM, maxPWM);
      leftPWM = constrain(leftPWM, minPWM, maxPWM);
    }

    // RIGHT
    else if (rightActive) {
      rightPWM = map(rightEffective,
                     activationMargin, 900,
                     minPWM, maxPWM);
      rightPWM = constrain(rightPWM, minPWM, maxPWM);
    }
  }

  // ---- MINIMUM ON TIME ----
  if (leftPWM > 0 || rightPWM > 0) {
    lastOnTime = millis();
  } else if (millis() - lastOnTime < minOnTimeMs) {
    leftPWM  = minPWM;
    rightPWM = minPWM;
  }

  ledcWrite(leftMotorPin, leftPWM);
  ledcWrite(rightMotorPin, rightPWM);

  Serial.print("L:");
  Serial.print(leftEffective);
  Serial.print(" R:");
  Serial.print(rightEffective);
  Serial.print(" | PWM L:");
  Serial.print(leftPWM);
  Serial.print(" R:");
  Serial.println(rightPWM);

  delay(25);
}