# log_ecg.py — pip install pyserial (or conda install pyserial)
import serial, csv, time

PORT     = "COM3"        # check Arduino IDE -> Tools -> Port
BAUD     = 250000
DURATION = 60
OUT      = "ecg_rest.csv"

ser = serial.Serial(PORT, BAUD, timeout=1)
time.sleep(2)
ser.reset_input_buffer()

rows, t0 = [], time.time()
while time.time() - t0 < DURATION:
    line = ser.readline().decode(errors="ignore").strip()
    if not line or line.startswith("t_us"):
        continue
    parts = line.split(",")
    if len(parts) == 3:
        rows.append(parts)

ser.close()
with open(OUT, "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["t_us", "adc", "leadsoff"])
    w.writerows(rows)

print(f"wrote {len(rows)} samples")