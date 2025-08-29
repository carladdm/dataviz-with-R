
![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Quarto](https://img.shields.io/badge/Quarto-222222?style=for-the-badge&logo=quarto&logoColor=white)
![GitHub last commit](https://img.shields.io/github/last-commit/carladdm/dataviz-with-R?style=for-the-badge)
<!--
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)
-->


# Data Visualization with R

This repository contains two projects focused on data visualization and spatial analysis using **R**. Each project is documented in **Quarto** (`.qmd`) and rendered to **HTML** for reproducibility and presentation.

---



## Repository Structure

```R
dataviz-with-R/
├── AG2/ # Project: Reservoir Volume Anomalies in Spain
│ ├── AG2.qmd
│ └── AG2.html
│
├── AG3/ # Project: Hillshade Maps of Portugal
│ ├── AG3.qmd
│ └── AG3.html
│
└── README.md
```


## Projects

### 🔹 AG2 — Reservoir Volume Anomalies in Spain
- **Goal**: Analyze anomalies in reservoir volumes across Spain, both at the **national** level and by **river basin**.  
- **Description**: The project visualizes the number of reservoirs and their volume anomalies expressed in **percentiles**, offering insights into hydrological variability and drought monitoring.  
- **Technologies**:  
  - R  
  - Quarto  
  - `ggplot2`, `dplyr`, and other tidyverse packages  

---

### 🔹 AG3 — Hillshade Maps of Portugal
- **Goal**: Generate **hillshade (relief) maps** of Portugal.  
- **Description**: Uses geospatial data from the **SNIG (Sistema Nacional de Informação Geográfica de Portugal)** to produce visualizations that highlight terrain features.  
- **Technologies**:  
  - R  
  - Quarto  
  - `tidyterra` and `giscoR` for spatial data processing and visualization  
  - Additional tidyverse packages for data manipulation  

---



## How to Use

  1. Clone the repository:
    ```bash
    git clone https://github.com/carladdm/dataviz-with-R.git
    cd dataviz-with-R
    ```
  2. Open the desired project folder (AG2 or AG3).
  3. Render the Quarto document:
  ```bash
    quarto render AG2.qmd
  ```
  or
  ```bash
    quarto render AG3.qmd
  ```
  4. Open the generated *.html* file in your browser to explore the visualizations.
  
## Requirements

Make sure you have the following installed:

- R
- Quarto
- Required R packages:

```R
  install.packages(c("ggplot2", "dplyr", "tidyterra", "giscoR"))
```
(plus any other packages referenced in the *.qmd* files)
## Objectives

- Apply R-based data visualization techniques to environmental and geospatial datasets.
- Explore hydrological data (reservoir anomalies in Spain) and terrain data (Portugal hillshade maps).
- Create reproducible and shareable reports using Quarto.

<!--
## License

This project is licensed under the MIT License — see the [MIT](https://choosealicense.com/licenses/mit/).
-->

