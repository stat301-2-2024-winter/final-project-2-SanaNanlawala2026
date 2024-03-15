library(ggplot2)
library(tidyverse)
library(here)
library(tidymodels)
library(doMC)
library(doParallel)
# load data + recipes
load("results/clean_split.rda")
load("results/clean_folds.rda")
load("results/rec_trees.rda")

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
rf_workflow <- workflow() |>
  add_model(rf_spec) |>
  add_recipe(rec_trees)

# tune hyperparameters -----
hardhat::extract_parameter_set_dials(rf_spec)

rf_mtry <- c(1, 17)
rf_min_n <- c(1, 10)
rf_params <- extract_parameter_set_dials(rf_spec) %>%
  update(mtry = mtry(rf_mtry)) |>
  update(min_n = mtry(rf_min_n))

#write out grid
rf_grid <- grid_regular(rf_params, levels = 5)
rf_grid

# fit workflows/models ----
tuned_rf <- tune_grid(rf_workflow,
                           clean_folds,
                           grid = rf_grid,
                           control = control_grid(save_workflow = TRUE))
tuned_rf
save(tuned_rf, file = here("results/tuned_rf.rda"))


# testing hyperparameters

autoplot_rf <-autoplot(tuned_rf, metric = "rmse")
save(autoplot_rf, file = here("exploration_results/autoplot_rf.rda"))
autoplot_rf

# retrieve rmse
rf_rmse <- as_workflow_set(
  knn = tuned_rf
)

rf_rmse |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  slice_min(mean, by = wflow_id) |>
  arrange(mean) |>
  select(`Model Type` = wflow_id,
         `RMSE` = mean,
         `Standard Error` = std_err,
         `Number of Computations` = n) |>
  knitr::kable(digits = c(NA, 2, 4, 0))

## collect RMSE
tuned_rf_params <- tuned_rf |>
  show_best(
    metric = "rmse") |>
  slice(1) |>
  select(mtry, min_n, .metric, mean, std_err)
tuned_rf_params
save(tuned_rf_params, file = here("exploration_results/tuned_rf_params.rda"))
