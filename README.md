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

## visual results

heres how it looks.

### time-domain
*top is the input audio. bottom is after the custom ifft put the pieces back together.*

![Time Domain Comparison](outputs/Sample_01_Speech/time_domain_graph.png)

### frequency-domain
*plotted up to the nyquist frequency. the hamming window stops the "bleeding" -> high magnitudes survive.*

![Frequency Domain Comparison](outputs/Sample_01_Speech/frequency_domain_graph.png)

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
