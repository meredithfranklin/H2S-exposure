# XGB Models 
# 2025-12-04
library(tidyverse)
library(stringr)
library(tidyr)
library(dplyr)
library(caret)
library(fastDummies)
select <- dplyr::select

savedir <- '../rfiles/xgboost_v41/'
daily_ha_train <- readRDS('../rfiles/data/daily_ha_train.rds')

da_predictors <- c('month', 'year', 'weekday', 'daily_wd', 'daily_ws', 
                'daily_downwind_ref', 'dist_wrp', 'dist_ref',
                'mon_utm_x', 'mon_utm_y', 'monthly_oil_2km', 'monthly_gas_2km', 
                'active_2km', 'inactive_2km', 'daily_downwind_wrp', 'elevation', 'EVI', 'num_odor_complaints',
                'dist_dc', 'closest_wrp_capacity', 'daily_temp', 'daily_hum', 'daily_precip') 

dm_predictors <- c('month', 'year', 'weekday', 'hourly_wd', 'hourly_ws', 
                   'hourly_downwind_ref', 'dist_wrp', 'dist_ref',
                   'mon_utm_x', 'mon_utm_y', 'monthly_oil_2km', 'monthly_gas_2km', 
                   'active_2km', 'inactive_2km', 'hourly_downwind_wrp', 'elevation', 'EVI', 'num_odor_complaints',
                   'dist_dc', 'closest_wrp_capacity', 'hourly_temp', 'hourly_hum', 'hourly_precip') 

################ Daily Average ###################
tune_grid <- expand.grid(nrounds = c(300, 500, 700),
                         max_depth = c(4, 6, 8, 10),
                         eta = c(0.05, 0.1, 0.2),
                         gamma = c(0.01, 0.001),
                         colsample_bytree = c(0.75, 1),
                         min_child_weight = c(0, 1, 5),
                         subsample = c(0.5, 0.75, 1))

set.seed(42)
tune_grid_subset <- tune_grid %>% slice_sample(n = 300)  

# Run algorithms using 10-fold cross validation
control <- trainControl(method="cv", 
                        number=10,
                        verboseIter=TRUE, 
                        search='grid',
                        savePredictions = 'final')

# Exclude Disaster
excl_disaster <- daily_ha_train %>% 
  filter(!(year == 2021 & month %in% 10:12)) %>% 
  select(all_of(c('H2S_daily_avg_from_hourly_avg', da_predictors))) %>% 
  filter(complete.cases(.))

train <- excl_disaster

fit.xgb_daha_excl_dis <- train(H2S_daily_avg_from_hourly_avg~.,
                             method = 'xgbTree',
                             data = train,
                             trControl=control,
                             tuneGrid = tune_grid_subset,
                             importance=TRUE, 
                             verbosity = 0, 
                             verbose=FALSE)
saveRDS(fit.xgb_daha_excl_dis,  paste0(savedir, 'fit.xgb_daha_excl_dis.rds'))
gc();rm(fit.xgb_daha_excl_dis)

# Everything w. Disaster Indicator 
everything <- daily_ha_train %>%
  select(all_of(c('H2S_daily_avg_from_hourly_avg', da_predictors, 'disaster'))) %>%
  filter(complete.cases(.))

train <- everything


# Everything w. Disaster Indicator 
fit.xgb_daha_dis_ind_unstrat <- train(H2S_daily_avg_from_hourly_avg~.,
                                 method = 'xgbTree',
                                 data = train,
                                 trControl=control,
                                 tuneGrid = tune_grid_subset,
                                 importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_daha_dis_ind_unstrat,  paste0(savedir, 'fit.xgb_daha_dis_ind_unstrat', '.rds'))
gc();rm(fit.xgb_daha_dis_ind_unstrat)

# Everything w.o Disaster Indicator
train <- everything %>% 
  select(-disaster)

# saveRDS(train, 'da_full_train_for_py.rds')

# Everything w.o Disaster Indicator 
fit.xgb_daha_full_unstrat <- train(H2S_daily_avg_from_hourly_avg~.,
                                         method = 'xgbTree',
                                         data = train,
                                         trControl=control,
                                         tuneGrid = tune_grid_subset,
                                         importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_daha_full_unstrat,  paste0(savedir, 'fit.xgb_daha_full_unstrat', '.rds'))
gc();rm(fit.xgb_daha_full_unstrat)

# Log H2S average
# Exclude Disaster
train <- excl_disaster %>% 
  mutate(H2S_daily_avg_from_hourly_avg = log(H2S_daily_avg_from_hourly_avg))

fit.xgb_daha_log_excl_dis <- train(H2S_daily_avg_from_hourly_avg~.,
                                     method = 'xgbTree',
                                     data = train,
                                     trControl=control,
                                     tuneGrid = tune_grid_subset,
                                     importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_daha_log_excl_dis,  paste0(savedir, 'fit.xgb_daha_log_excl_dis', '.rds'))
gc();rm(fit.xgb_daha_log_excl_dis)

# Everything w. Disaster Indicator
train <- everything %>%
  mutate(H2S_daily_avg_from_hourly_avg = log(H2S_daily_avg_from_hourly_avg))

### STRATIFIED
# fit.xgb_daha_log_dis_ind <- train(H2S_daily_avg_from_hourly_avg~.,
#                                     method = 'xgbTree',
#                                     data = train,
#                                     trControl=control_everything,
#                                     tuneGrid = tune_grid_subset,
#                                     importance=TRUE, verbosity = 0, verbose=FALSE)
# saveRDS(fit.xgb_daha_log_dis_ind,  paste0(savedir, 'fit.xgb_daha_log_dis_ind', '.rds'))
# gc();rm(fit.xgb_daha_log_dis_ind)

### UNSTRATIFIED
fit.xgb_daha_log_dis_ind_unstrat <- train(H2S_daily_avg_from_hourly_avg~.,
                                 method = 'xgbTree',
                                 data = train,
                                 trControl=control,
                                 tuneGrid = tune_grid_subset,
                                 importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_daha_log_dis_ind_unstrat,  paste0(savedir, 'fit.xgb_daha_log_dis_ind_unstrat', '.rds'))
gc();rm(fit.xgb_daha_log_dis_ind_unstrat)

# Everything w.o Disaster Indicator
train <- everything %>% 
  select(-disaster) %>%
  mutate(H2S_daily_avg_from_hourly_avg = log(H2S_daily_avg_from_hourly_avg))


### STRATIFIED
# fit.xgb_daha_log_full <- train(H2S_daily_avg_from_hourly_avg~.,
#                                  method = 'xgbTree',
#                                  data = train,
#                                  trControl=control_everything,
#                                  tuneGrid = tune_grid_subset,
#                                  importance=TRUE, verbosity = 0, verbose=FALSE)
# saveRDS(fit.xgb_daha_log_full,  paste0(savedir, 'fit.xgb_daha_log_full', '.rds'))
# gc();rm(fit.xgb_daha_log_full)

### UNSTRATIFIED
fit.xgb_daha_log_full_unstrat <- train(H2S_daily_avg_from_hourly_avg~.,
                                            method = 'xgbTree',
                                            data = train,
                                            trControl=control,
                                            tuneGrid = tune_grid_subset,
                                            importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_daha_log_full_unstrat,  paste0(savedir, 'fit.xgb_daha_log_full_unstrat', '.rds'))
gc();rm(fit.xgb_daha_log_full_unstrat)

################ Daily Max ###################
# Exclude Disaster
excl_disaster <- daily_ha_train %>% 
  filter(!(year == 2021 & month %in% 10:12)) %>% 
  select(c('H2S_daily_max_from_hourly_avg', dm_predictors)) %>% 
  filter(complete.cases(.))

train <- excl_disaster

fit.xgb_dmha_excl_dis <- train(H2S_daily_max_from_hourly_avg~.,
                               method = 'xgbTree',
                               data = train,
                               trControl=control,
                               tuneGrid = tune_grid_subset,
                               importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_dmha_excl_dis,  paste0(savedir, 'fit.xgb_dmha_excl_dis.rds'))
gc();rm(fit.xgb_dmha_excl_dis)

# Everything w. Disaster Indicator 
everything <- daily_ha_train %>%
  select(all_of(c('H2S_daily_max_from_hourly_avg', dm_predictors, 'disaster'))) %>%
  filter(complete.cases(.))

train <- everything

# Everything w. Disaster Indicator 
fit.xgb_dmha_dis_ind_unstrat <- train(H2S_daily_max_from_hourly_avg~.,
                                      method = 'xgbTree',
                                      data = train,
                                      trControl=control,
                                      tuneGrid = tune_grid_subset,
                                      importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_dmha_dis_ind_unstrat,  paste0(savedir, 'fit.xgb_dmha_dis_ind_unstrat', '.rds'))
gc();rm(fit.xgb_dmha_dis_ind_unstrat)

# Everything w.o Disaster Indicator
train <- everything %>% 
  select(-disaster)

# Everything w.o Disaster Indicator 
fit.xgb_dmha_full_unstrat <- train(H2S_daily_max_from_hourly_avg~.,
                                   method = 'xgbTree',
                                   data = train,
                                   trControl=control,
                                   tuneGrid = tune_grid_subset,
                                   importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_dmha_full_unstrat,  paste0(savedir, 'fit.xgb_dmha_full_unstrat', '.rds'))
gc();rm(fit.xgb_dmha_full_unstrat)

# Log H2S max
# Exclude Disaster
train <- excl_disaster %>% 
  mutate(H2S_daily_max_from_hourly_avg = log(H2S_daily_max_from_hourly_avg))

fit.xgb_dmha_log_excl_dis <- train(H2S_daily_max_from_hourly_avg~.,
                                   method = 'xgbTree',
                                   data = train,
                                   trControl=control,
                                   tuneGrid = tune_grid_subset,
                                   importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_dmha_log_excl_dis,  paste0(savedir, 'fit.xgb_dmha_log_excl_dis', '.rds'))
gc();rm(fit.xgb_dmha_log_excl_dis)

# Everything w. Disaster Indicator
train <- everything %>%
  mutate(H2S_daily_max_from_hourly_avg = log(H2S_daily_max_from_hourly_avg))

fit.xgb_dmha_log_dis_ind_unstrat <- train(H2S_daily_max_from_hourly_avg~.,
                                          method = 'xgbTree',
                                          data = train,
                                          trControl=control,
                                          tuneGrid = tune_grid_subset,
                                          importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_dmha_log_dis_ind_unstrat,  paste0(savedir, 'fit.xgb_dmha_log_dis_ind_unstrat', '.rds'))
gc();rm(fit.xgb_dmha_log_dis_ind_unstrat)

# Everything w.o Disaster Indicator
train <- everything %>% 
  select(-disaster) %>%
  mutate(H2S_daily_max_from_hourly_avg = log(H2S_daily_max_from_hourly_avg))

fit.xgb_dmha_log_full_unstrat <- train(H2S_daily_max_from_hourly_avg~.,
                                       method = 'xgbTree',
                                       data = train,
                                       trControl=control,
                                       tuneGrid = tune_grid_subset,
                                       importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_dmha_log_full_unstrat,  paste0(savedir, 'fit.xgb_dmha_log_full_unstrat', '.rds'))
gc();rm(fit.xgb_dmha_log_full_unstrat)

