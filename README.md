# High-resolution spatiotemporal exposure modeling of hydrogen sulfide (H₂S)

This repository accompanies *Modeling community hydrogen sulfide exposure in an urban industrial area during routine and extreme events* in Environmental Pollution https://doi.org/10.1016/j.envpol.2026.127916.

We present high-resolution spatiotemporal modeling of hydrogen sulfide (H₂S) using fenceline monitoring, meteorology, and geospatial information on industrial sources and land use. We present multiple predictive modeling approaches (GAM, XGBoost, and quantile XGBoost).

**What’s in this repo**
- **Merged H₂S datasets** at hourly and daily temporal resolution
- **Code** (Python and R) to fit and evaluate:
  - **GAM** (generalized additive models)
  - **XGB** (gradient-boosted trees via XGBoost)
  - **QXGB** (quantile XGBoost / quantile regression boosting)


We used 10-fold CV to hyperparamter tune, and three evaluation approaches: train-test split, leave-one-site-out (LOSO) and leave-one-event-out (LOEO) cross validation. 

Model predictions can be explored with this [Shinyapp](https://jerrywu.shinyapps.io/Prediction_viz/)

---

## Data overview

Data from 2020 to 2023 were collected from 15 fenceline monitors in the South Bay and Harbor Communities of Los Angeles County. See [SCAQMD](https://www.aqmd.gov/home/rules-compliance/rules/support-documents/rule-1180-refinery-fenceline-monitoring-plans) and [SCAQMD Rule 1180](https://xappprod.aqmd.gov/Rule1180CommunityAirMonitoring/) and [Torrance Refining](https://torc.data.spectrumenvsoln.com/data/map) for the raw data.

These data were merged with:

- [Dominguez Channel](https://geohub.lacity.org/datasets/lacounty::streams-usgs-nhd/about)
- [Water Treatment Plants](https://www.waterboards.ca.gov/resources/data_databases/site_map.html)
- [Oil and Gas wells and production](https://www.enverus.com/)
- [Refineries](https://www.eia.gov/states/ca/overview)
- [Greenspace/Vegetation Index](https://modis.gsfc.nasa.gov/data/dataprod/mod13.php)
- [Elevation](https://www.usgs.gov/centers/eros/science/usgs-eros-archive-digital-elevation-shuttle-radar-topography-mission-srtm-1)


If you use these data, please cite our manuscript.

---
