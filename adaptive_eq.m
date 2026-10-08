clear;
clc;
close all;

%% 1. Read audio
[x, fs] = audioread('mySpeech.wav');
x = mean(x, 2);             % Convert to mono
x = x - mean(x);            % Remove DC offset

%% 2. Calculate magnitude spectrum
N = length(x);
X = fft(x);

mag = abs(X(1:floor(N/2)+1));
f = (0:floor(N/2))' * fs / N;

%% 3. Calculate spectral centroid
if sum(mag) == 0
    error('The audio is silent. Please use another recording.');
end

centroid = sum(f .* mag) / sum(mag);

fprintf('Sample rate: %d Hz\n', fs);
fprintf('Duration: %.2f seconds\n', N/fs);
fprintf('Spectral centroid: %.2f Hz\n', centroid);

%% 4. Plot spectrum
figure;
plot(f, mag);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Input Audio Spectrum');
xline(centroid, '--r', 'Spectral centroid');
xlim([0 fs/2]);
%% 5. Select EQ gain using spectral centroid
if centroid < 2000
    gainDB = 3;
elseif centroid > 4000
    gainDB = -3;
else
    gainDB = 0;
end

fprintf('Selected high-frequency EQ gain: %+.1f dB\n', gainDB);

%% 6. Apply a first-order high-shelf EQ
% Low-frequency gain is 0 dB.
% High-frequency gain approaches gainDB.
fc = min(2000, fs/4);       % Transition frequency
g = 10^(gainDB/20);

K = tan(pi * fc / fs);
c = K / (1 + K);
p = (1 - K) / (1 + K);

bEQ = [g + (1-g)*c, -g*p + (1-g)*c];
aEQ = [1, -p];

y = filter(bEQ, aEQ, x);

%% 7. Analyse output audio
Y = fft(y);
magOut = abs(Y(1:floor(N/2)+1));

centroidOut = sum(f .* magOut) / sum(magOut);

fprintf('Input spectral centroid: %.2f Hz\n', centroid);
fprintf('Output spectral centroid: %.2f Hz\n', centroidOut);

%% 8. Save audio without clipping
if ~exist('results', 'dir')
    mkdir('results');
end

% Apply the SAME scaling to both files for comparison.
exportScale = max(1, max([abs(x); abs(y)]) / 0.99);

xSave = x / exportScale;
ySave = y / exportScale;

audiowrite('results/input_reference.wav', xSave, fs);
audiowrite('results/output_eq.wav', ySave, fs);

% Save the input spectrum figure from the earlier code.
saveas(gcf, 'results/input_spectrum.png');

%% 9. Compare input and output spectra
figure;

plot(f, 20*log10(mag / N / exportScale + 1e-12));
hold on;
plot(f, 20*log10(magOut / N / exportScale + 1e-12));

grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Spectrum Before and After Adaptive EQ');
legend('Input', 'Output', 'Location', 'best');
xlim([0 fs/2]);

saveas(gcf, 'results/spectrum_comparison.png');

%% 10. Plot EQ frequency response
fEQ = linspace(0, fs/2, 1024)';
z = exp(-1j * 2*pi*fEQ/fs);

H = (bEQ(1) + bEQ(2)*z) ./ ...
    (aEQ(1) + aEQ(2)*z);

figure;
plot(fEQ, 20*log10(abs(H)));
grid on;
xlabel('Frequency (Hz)');
ylabel('Gain (dB)');
title('Selected EQ Frequency Response');

saveas(gcf, 'results/eq_response.png');

%% 11. Save numerical results
summary = table(centroid, centroidOut, gainDB, exportScale, ...
    'VariableNames', {'InputCentroid_Hz', 'OutputCentroid_Hz', ...
    'HighFrequencyGain_dB', 'ExportScale'});

writetable(summary, 'results/summary.csv');

disp('Finished. Audio, figures and summary saved in results.');