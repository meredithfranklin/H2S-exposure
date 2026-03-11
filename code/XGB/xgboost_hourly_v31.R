# XGB Models hourly
# 2025-12-04

library(tidyverse)
library(stringr)
library(tidyr)
library(dplyr)
library(caret)
library(fastDummies)
# library(doParallel)

select <- dplyr::select

#n_cores <- detectCores(); n_cores
#registerDoParallel(cores = 8)

hourly_train <- readRDS('../rfiles/data/hourly_train.rds')

predictors <- c('month', 'year', 'weekday', 'julian', 'wd_avg', 'ws_avg', 
                'hourly_downwind_ref', 'dist_wrp', 'dist_ref',
                'mon_utm_x', 'mon_utm_y', 'monthly_oil_2km', 'monthly_gas_2km', 
                'active_2km', 'inactive_2km', 'hourly_downwind_wrp', 'elevation', 'EVI', 'num_odor_complaints',
                'dist_dc', 'closest_wrp_capacity', 'hourly_temp', 'hourly_hum', 'hourly_precip') 

savedir <- '../rfiles/xgboost_v41/'
############### Hourly Avg ###################
tune_grid <- expand.grid(nrounds = c(50, 100, 150),
                         max_depth = c(4, 5, 6),
                         eta = c(0.2, 0.4),
                         gamma = c(0.01, 0.001),
                         colsample_bytree = c(0.8, 1),
                         min_child_weight = 0,
                         subsample = c(0.75, 1))

# Run algorithms using 10-fold cross validation
control <- trainControl(method="cv", 
                        number=10,
                        verboseIter=TRUE, 
                        search='grid',
                        savePredictions = 'final'
                        )

# Exclude Disaster
excl_disaster <- hourly_train %>% 
  filter(!(year == 2021 & month %in% 10:12)) %>% 
  select(all_of(c('H2S_hourly_avg', predictors))) %>% 
  filter(complete.cases(.))

train <- excl_disaster

fit.xgb_ha_excl_dis <- train(H2S_hourly_avg~.,
                             method = 'xgbTree',
                             data = train,
                             trControl=control,
                             tuneGrid = tune_grid,
                             importance=TRUE, verbosity = 0, verbose=FALSE)

saveRDS(fit.xgb_ha_excl_dis, paste0(savedir, 'fit.xgb_ha_excl_dis.rds'))
gc();rm(fit.xgb_ha_excl_dis)

# Everything w. Disaster Indicator
everything <- hourly_train %>%
  select(all_of(c('H2S_hourly_avg', predictors, 'disaster'))) %>%
  filter(complete.cases(.))

fit.xgb_ha_dis_ind_unstrat <- train(H2S_hourly_avg~.,
                            method = 'xgbTree',
                            data = train,
                            trControl=control,
                            tuneGrid = tune_grid,
                            importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_ha_dis_ind_unstrat, paste0(savedir, 'fit.xgb_ha_dis_ind_unstrat.rds'))
gc();rm(fit.xgb_ha_dis_ind_unstrat)
        
# Everything w.o Disaster Indicator
train <- everything %>% 
  select(-disaster)

fit.xgb_ha_full_unstrat <- train(H2S_hourly_avg~.,
                                    method = 'xgbTree',
                                    data = train,
                                    trControl=control,
                                    tuneGrid = tune_grid,
                                    importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_ha_full_unstrat, paste0(savedir, 'fit.xgb_ha_full_unstrat.rds'))
gc();rm(fit.xgb_ha_full_unstrat)

# Log H2S hourly average
# Exclude Disaster
train <- excl_disaster %>% 
  mutate(H2S_hourly_avg = log(H2S_hourly_avg))

fit.xgb_ha_log_excl_dis <- train(H2S_hourly_avg~.,
                                     method = 'xgbTree',
                                     data = train,
                                     trControl=control,
                                     tuneGrid = tune_grid,
                                     importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_ha_log_excl_dis, paste0(savedir, 'fit.xgb_ha_log_excl_dis.rds'))
gc();rm(fit.xgb_ha_log_excl_dis)

# Everything w. Disaster Indicator
train <- everything %>%
  mutate(H2S_hourly_avg = log(H2S_hourly_avg))

fit.xgb_ha_log_dis_ind_unstrat <- train(H2S_hourly_avg~.,
                                    method = 'xgbTree',
                                    data = train,
                                    trControl=control,
                                    tuneGrid = tune_grid,
                                    importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_ha_log_dis_ind_unstrat, paste0(savedir, 'fit.xgb_ha_log_dis_ind_unstrat.rds'))
gc();rm(fit.xgb_ha_log_dis_ind_unstrat)

# Everything w.o Disaster Indicator
train <- everything %>% 
  select(-disaster) %>%
  mutate(H2S_hourly_avg = log(H2S_hourly_avg))

fit.xgb_ha_log_full_unstrat <- train(H2S_hourly_avg~.,
                                    method = 'xgbTree',
                                    data = train,
                                    trControl=control,
                                    tuneGrid = tune_grid,
                                    importance=TRUE, verbosity = 0, verbose=FALSE)
saveRDS(fit.xgb_ha_log_full_unstrat, paste0(savedir, 'fit.xgb_ha_log_full_unstrat.rds'))
gc();rm(fit.xgb_ha_log_full_unstrat)