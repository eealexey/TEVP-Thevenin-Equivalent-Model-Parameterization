# TEVP - Thevenin Equivalent Model Parameterization

**TEVP** (Thevenin Equivalent Model Parameterization) is a repository for processing experimental Li-ion battery data and parameterizing Thevenin equivalent circuit models (2RC) using Python and MATLAB.  
This workflow enables extraction of raw battery test data, creation of MATLAB pulse datasets, and model parameterization for advanced battery management and analysis.

---

## ⚡ Overview

The workflow consists of **three main stages**:

1. **Data Extraction** – Convert NDAX files from Neware battery testers into CSV format using Python.
2. **Pulse Dataset Creation** – Generate MATLAB tables (`plsDS`) containing pulse and relaxation data using the TEVP library.
3. **Model Parameterization** – Fit a 2RC Thevenin model in MATLAB/Simulink using the prepared pulse dataset.

The repository includes an example experiment (`P1-047`) and the corresponding test program:  
`Request parameterization LTO18650-150`.

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

````markdown
## 1️⃣ Extract Data from NDAX

### Define the step lists (`step_lists`) for CSV splitting:

- `step_lists` is a **list of lists**.  
- Each inner list defines which steps are combined into one CSV file.  

**Example:**

```python
step_lists = [[1], [2,3], [4,5]]
````

This produces three CSVs:

* `000.csv` → step 1

* `001.csv` → steps 2 and 3 (merged)

* `002.csv` → steps 4 and 5 (merged)

* **Time** in each CSV starts at 0 and continues throughout the merged steps.

### Rules for step selection:

* Each CSV should contain **one test pulse + subsequent relaxation** (`CC_DChg + rest`).
* The first CSV must contain only the **rest period before the first pulse**.
* For multiple cycles (36 pulses in the example program), `step_lists` can be generated programmatically:

```python
step_lists = [[1, 2]]  # initial steps outside the cycle
for i in range(0, N_cyc):
    step_lists += [(cycle_start + i*cycle_size + cyc).tolist()]
```

* Ensure only **executed pulses** are included if some cycles were skipped due to voltage limits.

### Run the script:

```bash
python Extract_NDA2CSV.py
```

* Processed CSV files are saved in a folder: `<input_folder>_processed`

---

## 2️⃣ Create Pulse Dataset (`plsDS`)

Use MATLAB script `create_plsDS.m` with the **TEVP library**.

### Setup:

* Ensure `create_plsDS.m` and TEVP folder (`@TEVP`) are in the **same path**, or add TEVP folder via **Set Path** in MATLAB.
* Edit parameters in:

```matlab
%% CHANGE THESE PARAMETERS FOR YOUR EXPERIMENT
soc_list = [...]  % SOC values at which pulses are applied
% Other parameters as documented in the script comments
```

### Output:

* MATLAB table `plsDS`:

  * Each row corresponds to **one pulse**.
  * Columns include metadata and raw data (`data` column).

* Save dataset:

```matlab
save("plsDS.mat", "plsDS")
```

### Tips:

* Rename files if working with multiple experiments in the same folder.
* `create_plsDS.m` estimates initial values for `R0`, `R1`, etc., stored in `plsDS`.

---

## 3️⃣ Model Parameterization

Use `RUN_estim.m` to fit a **2RC Thevenin model** in MATLAB/Simulink.

### Setup:

* Ensure Simulink model `inputModel_2RC_fit.slx` is in the **same folder** as the script.
* Specify pulse datasets:

```matlab
file_names = {"plsDS"}  % MATLAB .mat files
relax_tail = 600         % Relaxation duration after pulse in seconds
```

* Set **initial guesses** in:

```matlab
%% Initial guess values for the model parameters
```

### Process:

* Script updates `R0, R1, C1, R2, C2` in `plsDS`.
* Fitted results are stored in `fitres` column and saved with `model_tag`.
* Close Simulink window: select **No** when prompted to save changes.

---

## 📊 Data Handling Notes

* Ensure `step_lists` matches **executed pulses**; account for incomplete cycles.
* First CSV must include **pre-pulse rest** to obtain correct baseline voltage.
* `plsDS` combines **pulse metadata** and **time-series data** in a single table for parameterization.
* Recommended **relaxation tail**: 600 s (adjustable if needed).
* TEVP scripts assume a **2RC Thevenin model**; modify for other model orders if required.

---

## 📂 Example Data

Included folder: ` P1-047`

* NDAX files from experiment
* Program specification: `Request parameterization LTO18650-150`

---

## 🔍 Best Practices

* Verify **Python environment** before extraction.
* Always check `step_lists` corresponds to **actual test pulses**.
* Maintain **continuous timing across CSVs** for accurate voltage tracking.
* Backup `plsDS` before running parameterization with multiple experiments.

```

