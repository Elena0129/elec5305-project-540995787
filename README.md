# Adaptive Audio Equaliser Using Spectral Feature Analysis

This project is developed for ELEC5305.

The aim of this project is to develop a lightweight adaptive audio equaliser that automatically adjusts equalisation settings based on the spectral characteristics of an input audio signal.

The system will mainly use spectral centroid to estimate the brightness and tonal balance of the audio. Based on the analysis, simple EQ adjustments will be applied automatically.

## Method

The project will be implemented mainly in MATLAB.

The basic processing flow is:

Audio Input → Spectral Analysis → Spectral Centroid → Adaptive EQ Decision → Equalisation → Output Audio

## Expected Outcome

The final system will demonstrate how different audio signals can receive different EQ adjustments according to their spectral characteristics.

Project proposal, MATLAB code, test audio and results will be included in this repository.

## References

Some relevant work on automatic audio equalisation includes:

- G. Pepe et al., “Deep optimization of parametric IIR filters for audio equalization,” IEEE/ACM Transactions on Audio, Speech, and Language Processing, 2022.
- F. Mockenhaupt et al., “Automatic equalization for individual instrument tracks using convolutional neural networks,” DAFx24, 2024.

For the full methodology, timeline and references, please see the project proposal PDF in this repository.
