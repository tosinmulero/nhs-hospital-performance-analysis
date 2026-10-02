# NHS Hospital Performance & Patient Flow Analysis

## Dashboard

![NHS Hospital Performance Dashboard](images/nhs_dashboard_overview.png)


### Provider Performance Change Analysis

![Provider Change Analysis](images/nhs_provider_change_analysis.png)


---

## Project Overview

This project analyses NHS England A&E Attendances and Emergency Admissions provider-level data from **April to August 2026**.

The analysis focuses on:

- A&E attendance demand
- Four-hour performance
- Regional variation
- Type 1 Major A&E provider benchmarking
- Decision-to-admit delays
- 12-hour waits
- Provider performance changes
- Patient-flow trends

The project demonstrates an end-to-end analytics workflow using **Python, PostgreSQL, SQL, Power BI, Power Query and DAX**.

---

## Business Questions

1. How did total A&E demand change between April and August 2026?
2. How did national four-hour performance change?
3. How did performance vary across NHS England regions?
4. Which Type 1 providers reported higher or lower four-hour performance?
5. Which regions experienced the highest rates of 12-hour decision-to-admit waits?
6. How did severe admission delays change over time?
7. Which Type 1 providers improved most between April and August?
8. Which providers experienced the largest deterioration?
9. Did the composition of A&E demand change substantially during the period?

---

## Data Source

**NHS England — A&E Attendances and Emergency Admissions**

Provider-level monthly workbooks used:

- April 2026
- May 2026
- June 2026
- July 2026
- August 2026

Raw source workbooks are excluded from the repository.

---

## Tools & Technologies

- Python
- pandas
- Jupyter Notebook
- PostgreSQL
- SQL
- pgAdmin
- Power BI
- Power Query
- DAX
- VS Code
- Git
- GitHub

---

## Data Preparation

Python was used to:

- Import five NHS Excel workbooks
- Extract the `Provider Level Data` worksheet
- Standardise workbook structures
- Assign reporting months
- Clean provider identifiers and names
- Convert analytical fields to numeric types
- Validate attendance totals
- Validate four-hour performance calculations
- Detect duplicate provider-month records
- Identify missing values
- Separate non-provider data-quality notes
- Combine the five monthly datasets

The final cleaned dataset contains:

**956 provider-month records across 192 unique provider codes.**

---

## Data Quality

The dataset was checked for:

- Missing provider codes
- Missing provider names
- Missing regions
- Missing reporting months
- Duplicate provider-month records
- Attendance reconciliation errors
- Under-four-hour reconciliation errors
- Over-four-hour reconciliation errors
- Emergency-admission reconciliation errors
- Invalid percentage ranges

A source note stated that **East Kent Hospitals University NHS Foundation Trust's July 2026 data was incomplete and may be subject to revision**.

---

## Key Findings

### A&E Demand

Total A&E attendances peaked in **July 2026 at 2,487,580**.

| Month | Total Attendances |
|---|---:|
| April 2026 | 2,345,329 |
| May 2026 | 2,457,398 |
| June 2026 | 2,437,906 |
| July 2026 | 2,487,580 |
| August 2026 | 2,342,959 |

### Four-Hour Performance

National four-hour performance declined from **76.91% in April** to **75.04% in August 2026**.

The lowest monthly performance was **75.02% in June**.

### Regional Performance

Across the five-month period:

- London: approximately **78.18%**
- South West: approximately **71.97%**

All seven NHS England regions recorded lower four-hour performance in August than in April.

Largest April-to-August declines:

- East of England: **-2.48 percentage points**
- South East: **-2.48 percentage points**
- Midlands: **-2.00 percentage points**

### Type 1 Provider Benchmarking

The formal benchmark included **120 Type 1 providers with complete five-month reporting**.

| Statistic | Four-Hour Performance |
|---|---:|
| Mean | 61.59% |
| Median | 61.03% |
| 25th percentile | 54.64% |
| 75th percentile | 66.59% |
| Minimum | 36.24% |
| Maximum | 92.64% |

### 12-Hour Decision-to-Admit Waits

| Region | 12-Hour Waits per 1,000 A&E Admissions |
|---|---:|
| North West | 162.93 |
| Midlands | 162.87 |
| London | 157.65 |
| South East | 110.75 |
| South West | 96.31 |
| East of England | 95.94 |
| North East & Yorkshire | 46.10 |

The national rate peaked in **May at 124.96 per 1,000 admissions** and fell to **114.42 in August**.

### Four-Hour Performance vs 12-Hour Waits

Providers in the lowest Type 1 four-hour performance quartile recorded:

**136.80 twelve-hour waits per 1,000 A&E admissions**

compared with:

**88.90 per 1,000**

for providers in the top quartile.

The provider-level Pearson correlation was:

**r = -0.235**

This indicates a **weak negative association** and should not be interpreted as causal.

### Provider Performance Change

Largest improvement:

**Birmingham Women's and Children's NHS Foundation Trust**

- April: 80.94%
- August: 92.33%
- Change: **+11.39 percentage points**

Largest deterioration:

**York and Scarborough Teaching Hospitals NHS Foundation Trust**

- April: 62.17%
- August: 49.57%
- Change: **-12.60 percentage points**

---

## A&E Demand Mix

Demand composition remained relatively stable:

- Type 1 Major A&E: approximately **61%**
- Type 3 activity: approximately **36–37%**
- Type 2 activity: approximately **2%**

The A&E emergency admission rate remained around **16.3%–16.8%**.

---

## SQL Analysis

PostgreSQL was used to reproduce and extend the Python analysis.

SQL analysis includes:

- Data-quality validation
- National monthly performance
- Regional performance
- Monthly regional trends
- Patient-flow analysis
- 12-hour wait rates
- Type 1 provider benchmarking
- Provider performance change
- Power BI analytical view creation

Main SQL script:

`sql/01_nhs_hospital_performance_analysis.sql`

---

## Power BI

Power BI connects directly to PostgreSQL through:

`vw_ae_provider_performance`

DAX measures include:

- Four Hour Performance %
- Type 1 Four Hour Performance %
- A&E Admission Rate %
- 12 Hour Waits per 1,000
- Months Reported
- Apr-Aug Type 1 Change (pp)

Dashboard functionality includes:

- National KPI cards
- Region filtering
- Month filtering
- Monthly performance trends
- Regional comparisons
- Type 1 provider benchmarking
- 12-hour wait analysis
- Provider improvement analysis
- Provider deterioration analysis

---

## Project Structure

    nhs-hospital-performance-analysis/
    │
    ├── data/
    │   ├── raw/
    │   └── processed/
    │
    ├── images/
    │   ├── nhs_dashboard_overview.png
    │   └── nhs_provider_change_analysis.png
    │
    ├── notebooks/
    │   └── 01_data_preparation.ipynb
    │
    ├── powerbi/
    │   └── NHS_Hospital_Performance_Dashboard.pbix
    │
    ├── sql/
    │   └── 01_nhs_hospital_performance_analysis.sql
    │
    ├── .gitignore
    └── README.md

---

## Analytical Workflow

    NHS England Excel Workbooks
              ↓
    Python Cleaning & Validation
              ↓
    Processed Analytical Dataset
              ↓
           PostgreSQL
              ↓
          SQL Analysis
              ↓
     Power BI Analytical View
              ↓
          DAX Measures
              ↓
      Interactive Dashboard

---

## Analytical Notes

Four-hour performance is calculated from aggregated counts rather than by averaging provider-level percentages:

**Attendances within four hours ÷ Total attendances × 100**

12-hour decision-to-admit waits are normalised as:

**12-hour waits ÷ Emergency admissions via A&E × 1,000**

Provider benchmarking focuses on **Type 1 Major A&E departments** because different A&E department types have different operating models and patient populations.

---

## Author

**Oluwatosin Oluwaseun Mulero**

MSc Data Science

**Data Analytics | Business Intelligence | Data Science**