# HySyn: A genetically-encoded synthetic modulatory synapse to rewire neural circuits in vivo

## Contents

# Overview

# Citations
Hawk JD, et al. Integration of Plasticity Mechanisms within a Single Sensory Neuron of C. elegans Actuates a Memory. Neuron 97, 356-367 e354 (2018).
Gershow M, et al. Controlling airborne cues to study small animal navigation. Nat Methods 9, 290-296 (2012).
Luo L, et al. Bidirectional thermotaxis in Caenorhabditis elegans is mediated by distinct sensorimotor strategies driven by the AFD thermosensory neurons. Proc Natl Acad Sci U S A 111, 2776-2781 (2014).

# Dispersion Assay Tracking Analysis & Dispersion Assay Tracking/Speed Analysis
The purpose of this code was to monitor c. elegans migration on an agar pad over time, and calculate the mean speed over time as well as distanced traveled.
Methods overview: Synchronized young adult nematode populations were washed in M9 buffer then transferred by pipette to the 20°C behavioral test plate (22-cm x 22-cm agar plates). Worms were obliquely illuminated using an array of 624nm LEDs and migration was monitored for 120 min at 2fps using a MightEx camera (BCE-B050-U). Animal speed was analyzed using an adaptation of the MagatAnalyzer software package (Gershow et al. 2012, Luo et al. 2014) and custom MATLAB scripts (posted to this repository). Briefly, MagatAnalyzer uses a published and well-characterized machine vision approach to extract animal centroid position over time (Hawk et al. 2018). To estimate speed over the entire trajectory, we calculated the slope of a linear fit of the displacement for this centroid over time.



Head Thrashing Analysis

