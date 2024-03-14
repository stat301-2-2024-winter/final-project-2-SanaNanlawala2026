library(ggplot2)
library(tidyverse)
library(here)
library(tidymodels)
library(doMC)
library(doParallel)
# load data + recipes
load("results/clean_split.rda")
load("results/clean_folds.rda")
load("results/base_rec_main.rda")
load("results/clean_train.rda")
load("results/clean_test.rda")


# finalize workflow ----
final_wflow <- tuned_rf |>
  extract_workflow(tuned_rf) |>
  finalize_workflow(select_best(tuned_rf, metric = "rmse"))
# train final model ----
# set seed
set.seed(234546)

final_fit <- fit(final_wflow, clean_train)
final_fit

# get prediction results on testing data
final_predict <- predict(final_fit, new_data = clean_test)

