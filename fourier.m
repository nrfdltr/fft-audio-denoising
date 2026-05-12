% =========================================================================
% FFT/IFFT AUDIO DENOISING
% Developed for linear algebra project >:^l
% =========================================================================
clear; clc; close all;

%% 1. prep
% load audio (change audio name according to input)
[x_noisy, fs] = audioread('noisy_audio_01.wav');

% monophonic audio
if size(x_noisy, 2) > 1
    x_noisy = mean(x_noisy, 2);
end

% use 5 seconds of audio
max_samples = min(length(x_noisy), 5 * fs);
x_noisy = x_noisy(1:max_samples);

%% 2. framing + hamming window
L = 512;                        % frame length (must be power of 2)
H = L / 2;                      % hop size (50% overlap)
win = hamming_window(L);        % hamming to prevent spectral leakage
num_frames = floor((length(x_noisy) - L) / H) + 1;

% pre-allocate complex spectrum array
Y_complex = zeros(L, num_frames);

%% 3. forward FFT
disp('Computing FFT...');
for m = 1:num_frames
    idx_start = (m-1)*H + 1;
    idx_end   = idx_start + L - 1;
    frame = x_noisy(idx_start:idx_end) .* win;
    Y_complex(:, m) = custom_fft(frame);
end

%% 4. spectral subtraction (Wiener-style gain)
disp('Applying spectral subtraction...');

% estimate noise magnitude from first 20 frames (assumed noise-only)
noise_frames    = 20;
noise_mag_est   = mean(abs(Y_complex(:, 1:noise_frames)), 2);

% alpha: aggressiveness of subtraction (higher = more noise removed, more artifacts)
% beta:  spectral floor (prevents full nulling of a frequency bin)
alpha = 5.0;
beta  = 0.01;

S_clean_complex = zeros(L, num_frames);

for m = 1:num_frames
    Y_mag   = abs(Y_complex(:, m));
    Y_phase = angle(Y_complex(:, m));

    % gain = fraction of magnitude to keep per frequency bin
    gain = 1 - alpha .* (noise_mag_est ./ (Y_mag + eps));
    gain = max(gain, beta);             % spectral floor: gain never goes negative

    S_clean_complex(:, m) = (gain .* Y_mag) .* exp(1i * Y_phase);
end

%% 5. inverse FFT + overlap-add reconstruction
disp('Computing IFFT and reconstructing...');
x_denoised  = zeros(length(x_noisy), 1);
window_norm = zeros(length(x_noisy), 1);

for m = 1:num_frames
    s_n = custom_ifft(S_clean_complex(:, m));
    s_n = real(s_n);                    % discard floating-point imaginary residue

    idx_start = (m-1)*H + 1;
    idx_end   = idx_start + L - 1;

    % overlap-add
    x_denoised(idx_start:idx_end)  = x_denoised(idx_start:idx_end)  + s_n;

    % accumulate win.^2 for correct Hamming OLA normalization
    window_norm(idx_start:idx_end) = window_norm(idx_start:idx_end) + win.^2;
end

% normalize: cancels amplitude distortion from overlapping windows
x_denoised = x_denoised ./ (window_norm + eps);

%% 6. visualization
t = (0:length(x_noisy)-1) / fs;

% --- time domain ---
figure('Name', 'Time Domain', 'Color', 'w');

subplot(2,1,1);
plot(t, x_noisy, 'r');
title('Noisy Signal (Time Domain)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on; axis tight;

subplot(2,1,2);
plot(t, x_denoised, 'b');
title('Denoised Signal (Time Domain)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on; axis tight;

% --- frequency domain (middle frame) ---
figure('Name', 'Frequency Domain', 'Color', 'w');
mid_frame  = round(num_frames / 2);
freq_axis  = (0:L/2-1) * (fs / L);

subplot(2,1,1);
plot(freq_axis, abs(Y_complex(1:L/2, mid_frame)), 'r', 'LineWidth', 1.2);
title('Noisy Spectrum (mid-frame)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
grid on; axis tight;

subplot(2,1,2);
plot(freq_axis, abs(S_clean_complex(1:L/2, mid_frame)), 'b', 'LineWidth', 1.2);
title('Denoised Spectrum (mid-frame)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
grid on; axis tight;

%% 7. save output
disp('Saving output...');
x_out = x_denoised / max(abs(x_denoised) + eps);   % peak-normalize
audiowrite('denoised_output.wav', x_out, fs);
disp('Saved: denoised_output.wav');

% =========================================================================
% LOCAL FUNCTIONS
% =========================================================================

function X = custom_fft(x)
% Cooley-Tukey radix-2 decimation-in-time FFT.
% Input length N must be a power of 2.

    N = length(x);
    assert(mod(log2(N), 1) == 0, 'custom_fft: N must be a power of 2 (got %d)', N);

    if N == 1
        X = x;
        return;
    end

    x = x(:);                           % ensure column vector

    X_even = custom_fft(x(1:2:end));    % recurse on even-indexed samples
    X_odd  = custom_fft(x(2:2:end));    % recurse on odd-indexed samples

    k   = (0:N/2-1)';
    W_N = exp(-1i * 2 * pi * k / N);   % twiddle factors

    X = [ X_even + W_N .* X_odd ;
          X_even - W_N .* X_odd ];      % butterfly combine
end

function x = custom_ifft(X)
% Inverse FFT via the conjugate-symmetry identity:
%   IFFT(X) = (1/N) * conj(FFT(conj(X)))
% This reuses custom_fft so no separate recursion is needed.

    N = length(X);
    x = (1/N) * conj(custom_fft(conj(X(:))));
end

function w = hamming_window(L)
% Hamming window: w(n) = 0.54 - 0.46*cos(2*pi*n / (L-1))
    n = (0:L-1)';
    w = 0.54 - 0.46 * cos(2 * pi * n / (L - 1));
end