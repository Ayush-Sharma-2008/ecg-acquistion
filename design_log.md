# ECG Project — Design Log

## Session 1 — Soldering headers
Date: 8/31/2026

- Boards used: two AD8232, ordered as backups for each other
- Soldered header pins at 350°C
- Resoldered endpins due to low amounts of solder applied
- Verified with continuity test: all 6 pins beep to their pads, no beeps between adjacent pins

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
- Encountered a flickering power LED on the AD8232 amd spent significant time isolating the cause:
  - Ruled out both AD8232 boards (symptom appeared on both)
  - Ruled out the Arduino itself (Blink sketch ran normally, LED blinked correctly, TX/RX behaved as expected for each sketch)
  - A multimeter reading of 0V initially suggested a dead power rail,but this turned out to be a meter/probing error, not a real fault
  - Root cause: Turns out the Arduino IDE software was autoscaling, causing the appearence of no visible heart rate spike when it was actually occuring
- Confirmed a real heartbeat: 4 clear R-peaks in a 3-second window (t=10-13s), evenly spaced ~0.7-0.8s apart, consistent with ~75-85 bpm
- Noted: recording showed intermittent leads-off dropouts and
  significant noise (likely due to movement) between beats but this is to be expected on unfiltered signal

---

## Session 4 — Data logging and MATLAB import
Date: 9/05/2026

- Wrote log_ecg.py to record 60s of data to CSV at 500 Hz
- Verified actual sampling rate in MATLAB: [your Hz reading]
- Saved raw data as ecg_rest_confirmed_beat.csv
- Saved MATLAB workspace and script (ECGAcquistionCode.m) for reuse

---

## Session 5 — Filtering
Date: 9/06/2026

- Applied 0.5-40 Hz band-pass filter (2nd order Butterworth) plus 60 Hz notch, using filtfilt for zero phase distortion
- iirnotch failed due to undefined function, worked around it with a 2nd-order IIR notch filter at 60 Hz requiring no toolbox
- Saved comparison figure: ecg_filtered_comparison.png

---

## Session 6 — Peak detection and heart rate
Date: 9/07/2026

- Detected R-peaks using findpeaks with 200ms minimum distance
  (physiological refractory period) and an amplitude threshold of
  [your value]
- Initial HRV too high (Over 450ms), found the cause from fs(sampling rate) being computed from full data sample, which included multiple dropout gaps. That gap lowered fs to 342Hz instead of ~500Hz
- Fixed by auto-detecting the real dropout gap in the data first, restricting the analysis to the clean segment before it computed fs (499.57–499.67 Hz once corrected)

---

## Session 7 — Validation
Date: 9/08/2026

- Manually counted 18 beats by eye across the clean recording (t=8-22seconds)
- Found script bug: fs was referenced before it was computed, then it was referenced again later on
- Reworte script with gap-detection and fs calculation happening once after loading and cleaning the data
- Final Results:
  Sampling rate: 499.57 Hz
  Manual count (8–22s window): 18 beats
  Detector count (same window): 16 beats
  Accuracy: 88.9%
  Mean HR: 76.4 bpm
  SDNN: 204.5 ms
  RMSSD: 279.4 ms

---

## Session 8 — GitHub and writeup
Date:

- Repo created: [link]
- README written covering hardware, sampling, filtering, detection,
  results, limitations
