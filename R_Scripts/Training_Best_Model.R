# Train final model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)

# handle common conflicts
tidymodels_prefer()

load("results/clean_split.rda")
load("results/clean_folds.rda")
load("results/tuned_rf.rda")



# finalize workflow ----
final_wflow <- tuned_rf |>
  extract_workflow(tuned_rf) |>
  finalize_workflow(select_best(tuned_rf, metric = "rmse"))
# train final model ----
# set seed
set.seed(234546)

final_fit <- fit(final_wflow, clean_train)
final_fit
