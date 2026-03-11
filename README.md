# High-resolution spatiotemporal exposure modeling of hydrogen sulfide (H₂S)

This repository accompanies *Modeling community hydrogen sulfide exposure in an urban industrial area during routine and extreme events* in Environmental Pollution https://doi.org/10.1016/j.envpol.2026.127916.

We present high-resolution spatiotemporal modeling of hydrogen sulfide (H₂S) using fenceline monitoring, meteorology, and geospatial information on industrial sources and land use. We present multiple predictive modeling approaches (GAM, XGBoost, and quantile XGBoost).

**What’s in this repo**
- **Merged H₂S datasets** at hourly and daily temporal resolution
- **Code** (Python and R) to fit and evaluate:
  - **GAM** (generalized additive models)
  - **XGB** (gradient-boosted trees via XGBoost)
  - **QXGB** (quantile XGBoost / quantile regression boosting)
- We used 10-fold CV to hyperparamter tune and three evaluation approaches: train-test split, leave-one-site-out (LOSO) and leave-one-event-out (LOEO) cross validation. 

---

## Data overview

Data from 2020 to 2023 were collected from 15 fenceline monitors in the South Bay and Harbor Communities of Los Angeles County.


If you use these data, please cite our manuscript.

---
