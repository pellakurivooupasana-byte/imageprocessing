
# Image Processing using Verilog HDL and Python

A digital image processing system designed using Verilog HDL, with Python used to prepare the input image and generate the output image.

## Project Overview

This project implements basic image processing operations on an image using Verilog HDL. The image is converted into pixel data using Python, processed by the Verilog design, and the processed pixel data is converted back into an image using Python.

The design was developed using Verilog HDL and its output was verified by comparing the processed images with the original image.

## Working

The system takes the pixel data of an image and applies the selected processing mode.

* The input image is converted into pixel data using Python.
* The Verilog design reads the pixel data and applies the selected mode.
* The processed pixel data is written as output.
* Python converts the output data back into an image for viewing.

Supported modes:

* Original image
* Grayscale conversion
* Binary (threshold) conversion
* Color filters

The design can be extended to support more filters and FPGA implementation with VGA display.

## Tools & Technologies

* Verilog HDL
* [ModelSim / Intel Quartus Prime]
* Python
* RTL Design
* Combinational Logic

## Project Files

* [top.v] – Main Verilog design
* [top_tb.v] – Verilog testbench
* [rose.mif.py] – Python script to convert image to pixel data
* [view_frame_1.py] – Python script to convert output data to image
* [rose.png] – Original image
* [simulation_1,2,3,4,5] – Processed output images

## Simulation

The design was simulated and the output was checked for:

* Correct reading of pixel data
* Correct mode selection
* Accurate grayscale conversion
* Accurate binary conversion
* Correct color filter output

## Expected Output

The same input image gives a different output depending on the selected mode.

For example:

* Original mode → Same as input image
* Grayscale mode → Image in shades of gray
* Binary mode → Black and white image
* Color filter mode → Image with selected color emphasis

The output images are compared with the original to verify that each mode works correctly.

## Author

Voo Upasana
