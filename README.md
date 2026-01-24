# 🎧 Haptic Ear  
## Directional Sound Awareness System using Multi-Mic Sensing and Haptics

Haptic Ear is a hardware-first wearable system that converts **directional environmental sound** into **meaningful haptic feedback**, helping users understand where important sounds are coming from in real-world, noisy environments.

Instead of amplifying sound like traditional hearing aids, this system focuses on **situational awareness and safety** by translating sound direction and importance into vibration cues.

---

## 📌 Problem Statement

People with partial hearing loss or reduced auditory awareness often face difficulty in:
- Identifying **where** a sound is coming from (left, right, front)
- Distinguishing **important sounds** (horns, alarms) from background noise
- Reacting safely in **crowded, noisy environments** such as traffic or public spaces

Conventional solutions primarily amplify sound, which:
- Increases cognitive load
- Performs poorly in noisy environments
- Does not reliably convey sound direction

---

## 💡 Solution Overview

Haptic Ear is a **wearable, offline, low-latency system** that:
- Uses multiple microphones to detect sound direction
- Learns the ambient noise level continuously
- Identifies important sound events
- Provides localized vibration feedback based on sound direction and intensity

The user does not need to “listen harder”.  
The system communicates through **touch**.

---

## 🧠 Key Features

- 🎤 3-microphone directional sound sensing (Left, Right, Front)
- 📊 Adaptive noise floor tracking for real-world robustness
- 🧠 AI-augmented decision logic (on-device, lightweight)
- 📳 Directional haptic feedback using vibration motors
- 🔌 Fully offline operation (no cloud, no audio recording)
- 🔒 Privacy-preserving by design
- ⚡ Low latency and wearable-friendly

---

## 🧩 System Architecture

Microphones  
→ ESP32 ADC  
→ Envelope & Noise Floor Tracking  
→ Effective Energy Computation  
→ AI-Augmented Decision Layer  
→ Direction & Priority Detection  
→ PWM-Controlled Vibration Motors

---

## 🛠 Hardware Components

- ESP32 microcontroller (ADC + PWM)
- MAX9814 microphone modules
- Coin-type vibration motors
- 2N2222 BJTs or logic-level MOSFETs (motor drivers)
- Flyback diodes for motor protection
- Li-ion battery
- Boost converter for stable motor voltage
- Battery charging module

---

## 🔌 Hardware Design Highlights

- Separate boosted power rail for vibration motors to reduce ADC noise
- Flyback diodes and suppression components to reduce EMI
- Safe GPIO selection for ESP32 stability
- Designed to be compact, scalable, and wearable

---

## 🧠 AI Integration (On-Device & Explainable)

AI is used as an **enhancement layer**, not as a black box.

### AI capabilities include:
- Adaptive sensitivity based on environmental noise
- Sound priority classification (Noise / Voice / Alarm)
- False alert suppression (glitch rejection)
- Reduced alert fatigue and improved reliability

All AI logic is:
- Deterministic
- Explainable
- Offline
- Suitable for embedded firmware implementation

---

## 📈 MATLAB Simulation

A full MATLAB simulation is included to:
- Validate hardware and firmware logic
- Compare baseline vs AI-augmented behavior
- Visualize:
  - Raw microphone signals
  - Noise floor learning
  - Effective energy
  - Fixed vs adaptive thresholds
  - Directional haptic output
  - Alert count reduction

The simulation is used for design validation, analysis, and presentation.

---

## 📊 Results Summary

- AI system produces significantly fewer false alerts
- Important sounds (horns, alarms) are still detected reliably
- System adapts automatically to changing noise environments
- Reduced cognitive load and improved user trust

---

## 🧪 Use Cases

- Assistive wearable for people with hearing difficulty
- Urban traffic and pedestrian safety
- Industrial and noisy workplaces
- Research and academic demonstrations
- Foundation for future smart wearable devices

---

## 🚀 Future Enhancements

- Rear microphone for full 360° awareness
- Personalized haptic patterns per user
- Embedded ML model deployment on ESP32
- Smartphone visualization and configuration app
- Custom compact PCB for wearable deployment

---

## 🧑‍💻 Project Info

Project Name: Haptic Ear  
Domain: Assistive Hardware & Embedded Systems  
Focus: Directional sound awareness through haptics  

---

## 📜 License

This project is released for educational and research purposes.  
Commercial use requires permission from the authors.

---

## ⭐ Final Note

Haptic Ear is not about making sound louder.  
It is about helping users **understand their surroundings better**, safely and intuitively.
