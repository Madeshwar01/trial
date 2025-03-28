import numpy as np
import matplotlib.pyplot as plt

# 1. Read Vivado FFT Output
def read_vivado_output(filename="//home//mr_madeshwar_flightelectronics//Downloads//fft_output.txt"):
    real_parts = []
    imag_parts = []
    with open(filename, "r") as f:
        for line in f:
            try:
                re, im = map(int, line.strip().split())
                real_parts.append(re)
                imag_parts.append(im)
            except ValueError:
                # Handle lines that might not be valid data (e.g., empty lines)
                print(f"Skipping invalid line: {line.strip()}")
                pass  # Skip to the next iteration if parsing fails

    return np.array(real_parts), np.array(imag_parts)

# 2. Generate Expected FFT
def generate_expected_fft(fs, N, f1, f2):
    t = np.arange(N) / fs
    signal = np.sin(2 * np.pi * f1 * t) + np.cos(2 * np.pi * f2 * t)
    # Normalize and scale (as done in the input generation)
    signal_fixed = np.round(signal * 32767)
    fft_result = np.fft.fft(signal_fixed)
    return fft_result

# 3. Compare FFT Results
def compare_fft_results(vivado_fft, expected_fft, tolerance=0.1):
    vivado_magnitude = np.abs(vivado_fft)
    expected_magnitude = np.abs(expected_fft)

    # Normalize magnitudes for comparison
    vivado_magnitude /= np.max(vivado_magnitude)
    expected_magnitude /= np.max(expected_magnitude)

    # Compare magnitudes with tolerance
    diff = np.abs(vivado_magnitude - expected_magnitude)
    max_diff = np.max(diff)

    print(f"Maximum difference between FFT magnitudes: {max_diff}")

    if max_diff < tolerance:
        print("FFT results are within tolerance. FFT is likely correct.")
        return True
    else:
        print("FFT results exceed tolerance. FFT may be incorrect.")
        return False

# 4. Plot FFTs (Optional, for visualization)
def plot_fft_comparison(vivado_fft, expected_fft, fs, N, f1, f2):
    freqs = np.fft.fftfreq(N, 1/fs)
    plt.figure(figsize=(12, 6))
    plt.plot(freqs[:N//2], np.abs(vivado_fft)[:N//2], label="Vivado FFT")
    plt.plot(freqs[:N//2], np.abs(expected_fft)[:N//2], label="Expected FFT")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude")
    plt.title(f"FFT Comparison (f1={f1}Hz, f2={f2}Hz)")
    plt.legend()
    plt.grid()
    plt.show()

# --- Main Script ---

# FFT Parameters (same as VHDL and input generation)
fs = 1_000_000  # Sampling frequency
N = 1024       # FFT size
f1 = 100_000    # Signal frequency 1
f2 = 150_000    # Signal frequency 2

# Read Vivado output
real_parts, imag_parts = read_vivado_output("fft_output.txt")

# Check if the lengths are zero
if (len(real_parts) == 0 or len(imag_parts) == 0):
  print("Error: No data or invalid data read from fft_output.txt")
else:

  # Combine real and imaginary to complex numbers
  vivado_fft = real_parts + 1j * imag_parts

  # Generate expected FFT
  expected_fft = generate_expected_fft(fs, N, f1, f2)

  # Ensure both FFTs have the same length before comparison
  min_len = min(len(vivado_fft), len(expected_fft))
  vivado_fft = vivado_fft[:min_len]
  expected_fft = expected_fft[:min_len]

  # Compare and print result
  fft_correct = compare_fft_results(vivado_fft, expected_fft, tolerance=0.1)

  # Plot comparison (optional)
  if fft_correct:
      plot_fft_comparison(vivado_fft, expected_fft, fs, N, f1, f2)