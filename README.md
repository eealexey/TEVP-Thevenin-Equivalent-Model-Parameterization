# TEVP-Thevenin-Equivalent-Model-Parameterization 

# TEVP - Thevenin Equivalent Model Parameterization

**TEVP** (Thevenin Equivalent Model Parameterization) is a repository for processing experimental Li-ion battery data and parameterizing Thevenin equivalent circuit models (2RC) using Python and MATLAB.  
This workflow enables extraction of raw battery test data, creation of MATLAB pulse datasets, and model parameterization for advanced battery management and analysis.

---

## ⚡ Overview

The workflow consists of **three main stages**:

1. **Data Extraction** – Convert NDAX files from Neware battery testers into CSV format using Python.
2. **Pulse Dataset Creation** – Generate MATLAB tables (`plsDS`) containing pulse and relaxation data using the TEVP library.
3. **Model Parameterization** – Fit a 2RC Thevenin model in MATLAB/Simulink using the prepared pulse dataset.

The repository includes an example experiment (`П1-047`) and the corresponding test program:  
`Заявка параметризация LTO18650-150.docx`.

---

## 🛠️ Requirements

### Python
- Version: **3.10** or higher
- Packages:
  - `numpy`
  - `pandas`
  - [`NewareNDA`](https://github.com/Solid-Energy-Systems/NewareNDA)
- Recommended: **PyCharm + Anaconda**

### MATLAB
- Version: **R2024a** or higher (**Windows tested only**)
- Recommended Toolboxes (some optional):
  - Curve Fitting Toolbox
  - Global Optimization Toolbox
  - MATLAB Coder & Compiler
  - MATLAB Report Generator
  - Optimization Toolbox
  - Parallel Computing Toolbox
  - Signal Processing Toolbox
  - Simulink, Simscape, Simscape Electrical, Simscape Battery
  - System Identification Toolbox
  - Others as needed (see full list in documentation)

---

## 1️⃣ Extract Data from NDAX

Use the Python script `Extract_NDA2CSV.py` to convert NDAX files to CSV format.

### Steps:

1. Set the input folder and base filename:

```python
input_folder = r'.\П1-047'           # Folder containing NDAX files
input_base_name = '101-1-3-П1-047'   # Base filename without extension
```

2. Define the step lists (step_lists) for CSV splitting:
step_lists is a list of lists.
Each inner list defines which steps are combined into one CSV file.
Example:

```python
step_lists = [[1], [2,3], [4,5]]
```
This produces three CSVs:
000.csv → step 1
001.csv → steps 2 and 3 (merged)
002.csv → steps 4 and 5 (merged)
Time in each CSV starts at 0 and continues throughout the merged steps.


