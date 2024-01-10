################################################################################
## The following script fits a multivariate probit mode in Stan. Missing data ##
## is allowed. This uses the GHK algorithm for efficiency to draw from a      ##
## truncated multivariate normal.                                             ##
################################################################################

## Packages
library(tidyverse)
library(magrittr)
library(cmdstanr)
library(posterior)
set_cmdstan_path("C:/cmdstan/cmdstan-2.33.1")

## Stan Model (Note, this is adjustable based on exact model construction)
mod <- cmdstan_model("probit_ord_contpred.stan")

## Input Data
### Note, this section can be modified per data consraints and allocations
dat <- read.csv("data/US_diss_V2.csv")
dat %<>% select(agey, man_I1_L, man_I2_L, man_C_L,man_PM1_L, man_PM2_L,man_M1_L, man_M2_L, man_M3_L)
colnames(dat) <- c("Age","I1","I2","C","P3","P4","M1","M2","M3")

## Prep Stan data
standat <- list(D = 8,
                N = nrow(dat),
                y = as.matrix(dat[,2:9]),
                X = dat$Age,
                cats = 12)


## Fit Model
fit <- mod$sample(data = standat,
                  seed = 1991,
                  refresh = 500,
                  chains = 4,
                  parallel_chains = 4,
                  init = 0.01)

#################################END############################################
