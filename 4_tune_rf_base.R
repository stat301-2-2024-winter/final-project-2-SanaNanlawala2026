library(ggplot2)
library(tidyverse)
library(here)
library(tidymodels)
library(doMC)
library(doParallel)
# load data + recipes
load("results/clean_split.rda")
load("results/clean_folds.rda")
load("results/base_rec_trees.rda")

set.seed(234)
num_cores <- parallel::detectCores(logical = TRUE)
num_cores
# 8
num_cores <- registerDoMC(cores = 2)
num_cores


cl <- makePSOCKcluster(8)
set.seed(44)
registerDoParallel(cl)
# model specifications ----
rf_spec <-
  rand_forest(mode = "regression",
              trees = 1000,
              mtry = tune(),
              min_n = tune()) |>
  set_engine("ranger")

# define workflows ----
rf_base_workflow <- workflow() |>
  add_model(rf_spec) |>
  add_recipe(base_rec_trees)

# tune hyperparameters -----
hardhat::extract_parameter_set_dials(rf_spec)

rf_base_mtry <- c(1, 17)
rf_base_min_n <- c(1, 10)
rf_base_params <- extract_parameter_set_dials(rf_spec) %>%
  update(mtry = mtry(rf_base_mtry)) |>
  update(min_n = mtry(rf_base_min_n))

#write out grid
rf_base_grid <- grid_regular(rf_base_params, levels = 5)
rf_base_grid

# fit workflows/models ----
tuned_rf_base <- tune_grid(rf_base_workflow,
                           clean_folds,
                           grid = rf_base_grid,
                           control = control_grid(save_workflow = TRUE))
tuned_rf_base
save(tuned_rf_base, file = here("results/tuned_rf_base.rda"))


# testing hyperparameters

autoplot_rf_base <-autoplot(tuned_rf_base, metric = "rmse")
save(autoplot_rf_base, file = here("exploration_results/autoplot_rf_base4.rda"))
autoplot_rf_base

# Values
#rf_base_mtry <- c(1, 5)
#rf_base_min_n <- c(1, 10)
# rmse = 0.312 stderr = 0.00543

#rf_base_mtry <- c(1, 12)
#rf_base_min_n <- c(1, 10)
# rmse = 0.12 stderr = 0.0130

#rf_base_mtry <- c(1, 17)
#rf_base_min_n <- c(1, 10)
# rmse = 0.119 stderr = 0.0134
#WINNER: mtry = 13, min_n = 7

## collect RMSE
tuned_rf_base_params <- tuned_rf_base |>
  show_best(
    metric = "rmse") |>
  slice(1) |>
  select(mtry, min_n, .metric, mean, std_err)
tuned_rf_base_params
save(tuned_rf_base_params, file = here("exploration_results/tuned_rf_base_params.rda"))


## finalize workflow
rf_base_workflow <- rf_base_workflow |>
  finalize_workflow(select_best(tuned_rf_base, metric = "rmse"))
rf_base_workflow
