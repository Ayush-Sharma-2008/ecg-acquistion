# ECG Project — Design Log

## Session 1 — Soldering headers
Date: 8/31/2026

- Boards used: two AD8232 clones, ordered as backups for each other
- Soldered header pins at 350°C
- Resoldered Endpins due to low amounts of solder applied
- Verified with continuity test: all 6 pins beep to their pads, no
  beeps between adjacent pins

---

## Session 2 — Wiring and verification
Date: 9/1/2026

- Wired AD8232 to Arduino Uno: GND-GND, 3.3V-3.3V, OUTPUT-A0,
  LO+-D11, LO--D10. SDN left unconnected.
- Measured Arduino 3.3V pin directly before wiring: 3.2V V
- Verified each jumper individually with continuity after connecting them

---

## Session 3 — First signal and extended troubleshooting
Date: 9/04/2026

- Uploaded starter sketch, opened Serial Plotter
- First attempt: Noisy signal with no clear heart rate spike
- Encountered a flickering power LED on the AD8232 — spent significant time isolating the cause:
  - Ruled out both AD8232 boards (symptom appeared on both)
  - Ruled out the Arduino itself (Blink sketch ran normally, L LED
    blinked correctly, TX/RX behaved as expected for each sketch)
  - A multimeter reading of 0V initially suggested a dead power rail,
    but this turned out to be a meter/probing error, not a real fault
  - Root cause: Turns out the Arduino IDE software was autoscaling, causing the appearence of no visible heart rate spike when it was actually occuring
- Confirmed a real heartbeat: 4 clear R-peaks in a 3-second window
  (t=10-13s), evenly spaced ~0.7-0.8s apart, consistent with ~75-85 bpm
- Noted: recording showed intermittent leads-off dropouts and
  significant noise (likely due to movement) between beats — this is to be expected on raw,
  unfiltered signal

---

## Session 4 — Data logging and MATLAB import
Date:

- Wrote log_ecg.py to record 60s of data to CSV at 500 Hz
- Verified actual sampling rate in MATLAB: [your Hz reading]
- Saved raw data as ecg_rest_confirmed_beat.csv
- Saved MATLAB workspace and script (ECGAcquistionCode.m) for reuse

---

## Session 5 — Filtering
Date:

- Applied 0.5-40 Hz band-pass filter (2nd order Butterworth) plus
  60 Hz notch, using filtfilt for zero phase distortion
- [What changed visually between raw and filtered — be specific]
- Saved comparison figure: ecg_filtered_comparison.png

---

## Session 6 — Peak detection and heart rate
Date:

- Detected R-peaks using findpeaks with 200ms minimum distance
  (physiological refractory period) and an amplitude threshold of
  [your value]
- Results: [X] beats detected, mean HR [X] bpm, SDNN [X] ms,
  RMSSD [X] ms
- Saved figure: ecg_rpeaks_detected.png

---

## Session 7 — Validation
Date:

- Manually counted beats by [eye / pulse check] across the full
  recording: [X] beats
- Algorithm detected: [X] beats
- Accuracy: [X]%
- [Where it failed, if anywhere, and why — be honest, this is useful]

---

## Session 8 — GitHub and writeup
Date:

- Repo created: [link]
- README written covering hardware, sampling, filtering, detection,
  results, limitations
