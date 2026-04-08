# audio denoising via custom fft & spectral subtraction (apr2026-sem252)

![MATLAB](https://img.shields.io/badge/MATLAB-R2021a%2B-blue.svg)
![Status](https://img.shields.io/badge/Status-Complete-success.svg)
![Algorithm](https://img.shields.io/badge/Algorithm-Radix--2_FFT-orange.svg)

honestly just trying to survive this linear algebra project. made this from-scratch matlab pipeline without using `fft` or `ifft`.

---

## stuff it does

* **custom radix-2 fft:** achieve $O(N \log_2 N)$ efficiency, because the standard $N^2$ dft is very slow.
* **ifft:** uses the complex conjugate property to flip the spectrum back into the time domain.
* **manual hamming windowing:** tapers the frame boundaries to suppress the specxtral leakage.
* **overlap-add (ola) synthesis:** 50% overlapping hop size, so $H = L/2$.
* **magnitude thresholding:** used an over-subtraction factor $\alpha = 5.0$ and a spectral floor $\beta = 0.01$.

---

## sound glow-up
*before:*
1) <audio src="output/1/noisy_audio_test1.wav" controls></audio>
2) <audio src="output/3/noisy_audio_test3.wav" controls></audio>
3) <audio src="output/4/noisy_audio_test4.wav" controls></audio>
4) <audio src="output/6/noisy_audio_test6.wav" controls></audio>
5) <audio src="output/10/noisy_audio_test10.wav" controls></audio>

*after:*
1) <audio src="output/1/denoised_output1.wav" controls></audio>
2) <audio src="output/3/denoised_output3.wav" controls></audio>
3) <audio src="output/4/denoised_output4.wav" controls></audio>
4) <audio src="output/6/denoised_output6.wav" controls></audio>
5) <audio src="output/10/denoised_output10.wav" controls></audio>

---

## visual results

heres how it looks.

### time-domain
*top is the input audio. bottom is after the custom ifft put the pieces back together.*

![Time Domain Comparison](output/1/time_domain_analysis.png)

### frequency-domain
*plotted up to the nyquist frequency. the hamming window stops the "bleeding" -> high magnitudes survive.*

![Frequency Domain Comparison](output/1/frequency_domain_analysis.png)

---

## usage

1.  **clone repo:**
    ```bash
    git clone [https://github.com/nrfdltr/audio-denoising-fft.git](https://github.com/nrfdltr/audio-denoising-fft.git)
    ```
2.  **run the script:** open matlab and run `denoise_audio.m`
3.  i go sleep now. zzzzzZZz

---

## references
* **audio data:** from rajat borkar on kaggle. 
* **math:** tripathi et al. (2024) for hamming-ola & threshold, harris (1978) for hamming, mota (2022) for dft/fft, wen (2025) for ifft, brunton (2022) for complex conjugate
* **implementation:** followed the *handbook of real-time fast fourier transforms* because the butterfly signal flow diagrams.
