% =========================================================================
% DFT/FFT FOR AUDIO DENOISING
% Developed for linear algebra project >:^l
% =========================================================================
clear; clc; close all;

%% 1. prep
% load audio (change audio name according to input)
[x_noisy, fs] = audioread('strang.wav');

% monophonic audio
if size(x_noisy, 2) > 1
    x_noisy = mean(x_noisy, 2); 
end

% use 5 seconds of audio
max_samples = min(length(x_noisy), 5 * fs); 
x_noisy = x_noisy(1:max_samples);

%% 2. hamming
L = 512;                        % frame length
H = L / 2;                      % hop size (50% overlap)
win = hamming_window(L);        % hamming to prevent spectral leakage
num_frames = floor((length(x_noisy) - L) / H) + 1;

% pre-allocate complex spectrum array
Y_complex = zeros(L, num_frames);

%% 3. fft (forward)
disp('Computing FFT');
for m = 1:num_frames
    % extract then hamming
    idx_start = (m-1)*H + 1;
    idx_end = idx_start + L - 1;
    frame = x_noisy(idx_start:idx_end) .* win;
    
    % fft
    Y_complex(:, m) = custom_fft(frame); 
end

%% 4. spectral subtraction
disp('Applying magnitude thresholding');

% average noise magnitude
noise_frames = 20; 
noise_mag_est = mean(abs(Y_complex(:, 1:noise_frames)), 2);

% spectral subtract parameters
alpha = 5.0;
beta = 0.01;

S_clean_complex = zeros(L, num_frames);

for m = 1:num_frames
    % define mag & phase
    Y_mag = abs(Y_complex(:, m));
    Y_phase = angle(Y_complex(:, m)); 
    
    % scale freq mag (1 by 1)
	% 'gain' is percentage of how much audio to keep (for each freq)
	gain = 1 - alpha .* (noise_mag_est ./ (Y_mag + eps));
	gain = max(gain, beta); % beta is spectral floor so gain is not negative
    
    % gain to mag only
    S_clean_mag = gain .* Y_mag;
    
    % reconstruct
    S_clean_complex(:, m) = S_clean_mag .* exp(1i * Y_phase);
end

%% 5. ifft
disp('Computing IFFT and reconstructing signal');
x_denoised = zeros(length(x_noisy), 1);
window_norm = zeros(length(x_noisy), 1);

for m = 1:num_frames
    S_k = S_clean_complex(:, m);

    % x = (1/N) * conj(FFT(conj(X)))
    s_n = (1/L) * conj(custom_fft(conj(S_k)));
    s_n = real(s_n); % extract real part
    
    % overlap-add
    idx_start = (m-1)*H + 1;
    idx_end = idx_start + L - 1;
    
    x_denoised(idx_start:idx_end) = x_denoised(idx_start:idx_end) + s_n;
    window_norm(idx_start:idx_end) = window_norm(idx_start:idx_end) + win;
end

% normalize by overlapped windows to prevent amplitude distortion
x_denoised = x_denoised ./ (window_norm + eps);

%% 6. visualization

% time-domain analysis
figure('Name', 'Time Domain Analysis', 'Color', 'w');
t = (0:length(x_noisy)-1) / fs;

subplot(2,1,1);
plot(t, x_noisy, 'r');
title('Original Noisy Signal (Time Domain)');
xlabel('Time (seconds)'); ylabel('Amplitude');
grid on; axis tight;

subplot(2,1,2);
plot(t, x_denoised, 'b');
title('Denoised Signal (Time Domain)');
xlabel('Time (seconds)'); ylabel('Amplitude');
grid on; axis tight;

% freq-domain analysis
figure('Name', 'Frequency Domain Analysis', 'Color', 'w');
mid_frame = round(num_frames / 2);
freq_axis = (0:L/2-1) * (fs / L); 

subplot(2,1,1);
plot(freq_axis, abs(Y_complex(1:L/2, mid_frame)), 'r', 'LineWidth', 1.2);
title('Noisy Frequency Spectrum');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
grid on; axis tight;

subplot(2,1,2);
plot(freq_axis, abs(S_clean_complex(1:L/2, mid_frame)), 'b', 'LineWidth', 1.2);
title('Denoised Frequency Spectrum');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
grid on; axis tight;

%% 7. output .wav
disp('Saving output file');
x_denoised_norm = x_denoised / max(abs(x_denoised));

output_filename = 'denoised_output.wav';
audiowrite(output_filename, x_denoised_norm, fs);
fprintf('Saved to: %s\n', output_filename);

% =========================================================================
% LOCAL FUNCTIONS
% =========================================================================
function X = custom_fft(x)
    % FFT algorithm
    
    N = length(x);
    
    % recursion
    if N <= 1
        X = x;
        return;
    end
    
    % column vector
    x = x(:);
    
    % split even & odd
    X_even = custom_fft(x(1:2:end));
    X_odd  = custom_fft(x(2:2:end));
    
    % twiddle factor
    k = (0:N/2-1)';
    W_N = exp(-1i * 2 * pi * k / N);
    
    X = zeros(N, 1);
    X(1:N/2)     = X_even + W_N .* X_odd;
    X(N/2+1:N)   = X_even - W_N .* X_odd;
end

function w = hamming_window(L)
    % manual hamming window
    n = (0:L-1)';
    w = 0.54 - 0.46 * cos(2 * pi * n / (L - 1));
end