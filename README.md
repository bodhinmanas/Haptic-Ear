# 🦻 The Haptic Ear: Listening with Your Skin
> **Status:** ✅ Hardware Prototype v1.0 (Tested on ESP32)

**The Haptic Ear** is a wearable assistive device that converts sound direction into haptic feedback. It allows deaf individuals to "feel" the direction of honking horns or approaching vehicles, covering their blind spots.


## 🚨 The Problem
Deaf pedestrians and cyclists are at high risk on Indian roads because they cannot hear threats approaching from behind. Visual reliance isn't enough for 360° safety.

## 💡 How It Works
1.  **Input:** Two **MAX9814** Auto-Gain Microphones listen to the environment.
2.  **Processing:** An **ESP32** analyzes the analog audio differential in real-time.
3.  **Algorithm:** A smart "Noise Gate" filters out wind/background noise.
4.  **Output:** If a loud sound is detected on the Left, the **Left Vibration Motor** pulses.

## 🛠️ Hardware Setup
| Component | Pin Connection (ESP32) |
| :--- | :--- |
| **Left Mic** (MAX9814) | GPIO 34 (ADC1) |
| **Right Mic** (MAX9814) | GPIO 35 (ADC1) |
| **Left Motor** (Driver) | GPIO 25 (DAC1) |
| **Right Motor** (Driver) | GPIO 26 (DAC2) |


## 💻 Key Code Features
* **Adaptive Noise Gate:** Ignores ambient noise (threshold set to `80`).
* **PWM Motor Control:** Motors run at ~70% duty cycle to prevent overheating (3V motors on 5V rail).
* **Exponential Moving Average (EMA):** Smooths out sensor jitter for a clean haptic pulse.

## 🚀 Future Roadmap
* **Machine Learning:** Integrating TensorFlow Lite on ESP32 to distinguish *Horns* from *Construction Noise*.
* **PCB Design:** Moving from bread-board to a custom wearable PCB.

---
*Built for TechSprint GDGC Hackathon 2026.*