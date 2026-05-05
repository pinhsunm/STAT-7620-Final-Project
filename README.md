# STAT 7620 Final Project 


## Core Simulation File
* **`PCGrad_sim_final.R`**: This is the **primary R simulation code** used in the final project report. 
    * It defines two distinct loss functions ($L_1$ and $L_2$).
    * It implements the PCGrad projection logic: $g_i = g_i - \frac{g_i \cdot g_j}{\|g_j\|^2} g_j$ if $g_i \cdot g_j < 0$.
    * It contains the `ggplot2` visualization of the path for parameter updates.


## Dependencies
```R
# Required libraries for simulation
library(torch)
library(ggplot2)
library(dplyr)
library(tidyr)
