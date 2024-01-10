################################################################################
## The following script imports a fitted Stan model with log probability      ##
## density values, computes the log posterior predictive density, and         ##
## visualizes the data against possible age of the unknown.                   ##
################################################################################

## Packages
### Note - remember to setwd and clear workspace.
library(posterior)
library(tidyverse)
library(magrittr)
library(matrixStats)

## Input Training Data to Get Baseline Age
### Note - this is adjustable based on modeling conditions. 
train <- read.csv("data/US_diss_V2.csv")
train %<>% select(agey,man_I1_L, man_I2_L, man_C_L, man_PM1_L, man_PM2_L, 
                  man_M1_L, man_M2_L, man_M3_L)
train$rows <- rowSums(is.na(train))
train %<>% filter(rows <= 6)

## Input Stan Generated Quantities Model
fit_gq <- readRDS("fitted_models/naledi_uw_101_377.rds")

## Extract Log Likelihood Values
log_lik <- as_draws_matrix(fit_gq$draws("lp"))

## Calculate the Expected Log Posterior Predictive Distribution
lppd <- apply(X = log_lik, MARGIN = 2, function(x) logSumExp(x) - log(4000))

## Plot the Age against the Log Posterior Predictive Distribution
plot(train$agey, lppd, col = "steelblue", xlab = "Age [years]", 
     ylab = "Log Predictive Density")
axis(1, seq(0,21,1))
abline(v = train$agey[which.max(lppd)], col="tomato")

#################################END############################################
