T = readtable('C:\Users\itzay\ecg_rest_confirmed_beat.csv');
T = T(T.leadsoff == 0, :);
t_full = (T.t_us - T.t_us(1)) / 1e6;
v_full = T.adc * (3.3/1023);

%% Find the real dropout gap and cut everything after it
dt_full = diff(t_full);
gap_idx = find(dt_full > 0.1, 1, 'first');
if isempty(gap_idx)
    t = t_full; v = v_full;
else
    fprintf('Gap found after sample %d, at t=%.2fs, size=%.1fms\n', ...
        gap_idx, t_full(gap_idx), dt_full(gap_idx)*1000);
    t = t_full(1:gap_idx);
    v = v_full(1:gap_idx);
end

%% Compute the real sampling rate -- ONCE, right here, before anything uses it
dt = diff(t);
fs = 1/mean(dt);
fprintf('actual sampling rate: %.2f Hz\n', fs);

%% Raw plot
figure;
plot(t, v);
ylim([0 3.3]);
xlabel('Time (s)'); ylabel('Voltage (V)');
title('Raw ECG');
xlim([10 13]);
save('ecg_session3_workspace.mat', 'T', 't', 'v')
saveas(gcf, 'ecg_heartbeat_confirmed.png')

%% Filter
[b, a] = butter(2, [0.5 40]/(fs/2), 'bandpass');
xf = filtfilt(b, a, v);

% Manual 60 Hz notch, no toolbox required
w0 = 2*pi*60/fs;
r = 0.985;
bn = [1, -2*cos(w0), 1];
an = [1, -2*r*cos(w0), r^2];
xf = filtfilt(bn, an, xf);

figure;
subplot(2,1,1);
plot(t, v); title('Raw'); xlabel('Time (s)'); ylabel('V'); xlim([10 15]);
subplot(2,1,2);
plot(t, xf); title('Filtered'); xlabel('Time (s)'); ylabel('V'); xlim([10 15]);
saveas(gcf, 'ecg_filtered_comparison.png')

%% Peak detection
minDist = round(0.20 * fs);        % 200 ms refractory period
thr = 0.4 * max(xf);
[pks, locs] = findpeaks(xf, 'MinPeakHeight', thr, 'MinPeakDistance', minDist);

%% Validation against manual count
window = t(locs) >= 8 & t(locs) <= 22;
detector_count_window = sum(window);
fprintf('Manual count (8-22s): 18\n');
fprintf('Detector count (8-22s): %d\n', detector_count_window);
fprintf('Accuracy: %.1f%%\n', min(18,detector_count_window)/max(18,detector_count_window)*100);

figure;
plot(t, xf); hold on;
plot(t(locs), pks, 'rv', 'MarkerFaceColor', 'r');
xlabel('Time (s)'); ylabel('V');
title('Detected R-peaks');
xlim([10 15]);
saveas(gcf, 'ecg_rpeaks_detected.png')

%% Heart rate and HRV
rr = diff(t(locs));
valid = rr > 0.33 & rr < 1.5;
rr = rr(valid);
hr = 60 ./ rr;

fprintf('beats detected: %d\n', numel(locs));
fprintf('kept %d of %d RR intervals as physiologically valid\n', sum(valid), numel(rr)+sum(~valid));
fprintf('mean HR: %.1f bpm\n', mean(hr));
fprintf('SDNN: %.1f ms\n', std(rr)*1000);
fprintf('RMSSD: %.1f ms\n', sqrt(mean(diff(rr).^2))*1000);