################################################################################
## The following script quantifies the log [pointwise] posterior predictive   ##
## distribution assuming a previously fit Stanmodel, a generated quantities   ##
## model file, and test data input.                                           ##
################################################################################

## Packages
library(tidyverse)
library(magrittr)
library(cmdstanr)
library(posterior)
library(loo)
set_cmdstan_path("C:/cmdstan/cmdstan-2.33.1")

## Training Data
train <- read.csv("data/US_diss_V2.csv")
train %<>% select(agey,man_I1_L, man_I2_L, man_C_L, man_PM1_L, man_PM2_L, man_M1_L, man_M2_L, man_M3_L)
train$rows <- rowSums(is.na(train))
train %<>% filter(rows <= 6)

## Test Data
test <- read.csv("data/Hominin_Comparison_Data.csv")
test %<>% select(medrec,man_I1_L, man_I2_L, man_C_L, man_PM1_L, man_PM2_L, man_M1_L, man_M2_L, man_M3_L)
test[is.na(test)] <- 99

## Fitted Model (Note, this is adjustable given the comparison at hand)
fit <- readRDS("fitted_models/human_mod.RDS") 

## Generated Quantities Model (Note, this is adjustable based on model)
gq_mod <- cmdstan_model("probit_generated_quant.stan")

## Data Prep for GQ Model (Note, y is adjustable)
standat <- list(D = 8, 
                N = nrow(train), 
                y = test[6,2:9],
                X = train$agey,
                cats = 12)

## Run Stan generated quantities
fit_gq <- gq_mod$generate_quantities(fit, data = standat, seed = 123, parallel_chains = 4)

## Save Model for Later Use
fit_gq$save_object("fitted_models/naledi_uw_101_377.rds")

#################################END############################################
