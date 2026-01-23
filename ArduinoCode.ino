#include <EloquentTinyML.h>
#include "model.h"

// ================= ML CONFIG =================
#define N_INPUTS 5
#define N_OUTPUTS 3
#define TENSOR_ARENA_SIZE 8 * 1024

Eloquent::TinyML::TfLite<N_INPUTS, N_OUTPUTS, TENSOR_ARENA_SIZE> ml;

// ================= MIC INPUTS =================
const int micLeft   = 34;
const int micCenter = 35;
const int micRight  = 32;

// ================= MOTORS =====================
const int motorBL = 25;
const int motorBR = 26;
const int motorFL = 27;
const int motorFR = 14;

// ================= TUNING =====================
const int deadZone = 40;
const int maxPWM   = 255;
const int dcBias   = 2048;

unsigned long lastMLTime = 0;

// ================= ENVELOPE ===================
int getEnvelope(int pin) {
  static int prev = 0;
  int raw = analogRead(pin);
  int env = abs(raw - dcBias);
  env = (env + prev) / 2;
  prev = env;
  return env;
}

// ================= SETUP =====================
void setup() {
  Serial.begin(115200);
  delay(2000);

  pinMode(motorBL, OUTPUT);
  pinMode(motorBR, OUTPUT);
  pinMode(motorFL, OUTPUT);
  pinMode(motorFR, OUTPUT);

  analogWrite(motorBL, 0);
  analogWrite(motorBR, 0);
  analogWrite(motorFL, 0);
  analogWrite(motorFR, 0);

  ml.begin(model);

  Serial.println("System ready: MIC + Direction + TinyML");
}

// ================= LOOP ======================
void loop() {

  int L = getEnvelope(micLeft);
  int C = getEnvelope(micCenter);
  int R = getEnvelope(micRight);

  if (L < deadZone) L = 0;
  if (C < deadZone) C = 0;
  if (R < deadZone) R = 0;

  int pwmLeft   = map(L, 0, 2048, 0, maxPWM);
  int pwmCenter = map(C, 0, 2048, 0, maxPWM);
  int pwmRight  = map(R, 0, 2048, 0, maxPWM);

  int rearLeftPWM  = max(pwmLeft,  pwmCenter);
  int rearRightPWM = max(pwmRight, pwmCenter);
  int frontLeftPWM  = rearLeftPWM;
  int frontRightPWM = rearRightPWM;

  float urgency = 0.2;

  if (millis() - lastMLTime > 100) {
    lastMLTime = millis();

    float rms  = (L + C + R) / 3.0 / 2048.0;
    float zcr  = abs(L - R) / 2048.0;
    float low  = C / 2048.0;
    float mid  = (L + R) / 2.0 / 2048.0;
    float high = abs(L - R) / 2048.0;

    float input[N_INPUTS] = { rms, zcr, low, mid, high };
    float* output = ml.predict(input);

    float vehicle = output[0];
    float alarm   = output[1];
    float noise   = output[2];

    float maxScore = max(vehicle, max(alarm, noise));

    if (maxScore > 0.6) {
      if (alarm > vehicle && alarm > noise) urgency = 1.0;
      else if (vehicle > noise) urgency = 0.7;
      else urgency = 0.3;
    }

    Serial.print("V:");
    Serial.print(vehicle, 2);
    Serial.print(" A:");
    Serial.print(alarm, 2);
    Serial.print(" N:");
    Serial.println(noise, 2);
  }

  rearLeftPWM  *= urgency;
  rearRightPWM *= urgency;
  frontLeftPWM *= urgency;
  frontRightPWM *= urgency;

  analogWrite(motorBL, rearLeftPWM);
  analogWrite(motorBR, rearRightPWM);
  analogWrite(motorFL, frontLeftPWM);
  analogWrite(motorFR, frontRightPWM);

  delay(30);
}
