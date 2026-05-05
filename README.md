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

## References

Please cite as:

```bibtex
@inproceedings{NEURIPS2020_3fe78a8a,
 author = {Yu, Tianhe and Kumar, Saurabh and Gupta, Abhishek and Levine, Sergey and Hausman, Karol and Finn, Chelsea},
 booktitle = {Advances in Neural Information Processing Systems},
 pages = {5824--5836},
 publisher = {Curran Associates, Inc.},
 title = {Gradient Surgery for Multi-Task Learning},
 url = {https://proceedings.neurips.cc/paper_files/paper/2020/file/3fe78a8acf5fda99de95303940a2420c-Paper.pdf},
 volume = {33},
 year = {2020}
}

@misc{PCGrad_R_Torch_Sim,
  author = {Pin-Hsun Mao},
  title = {Pin-Hsun Mao/R_Torch-PCGrad_Simulation},
  url = {https://github.com/pinhsunm/STAT-7620-Final-Project},
  year = {2020}
}
```
