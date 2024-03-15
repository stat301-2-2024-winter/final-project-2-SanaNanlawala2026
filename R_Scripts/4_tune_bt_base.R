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

library(xgboost)

bt_spec <- boost_tree(mode = "regression",
                       min_n = tune(),
                       mtry = tune(),
                       learn_rate = tune()) |>
  set_engine("xgboost")

# define workflows ----
bt_base_workflow <- workflow() |>
  add_model(bt_spec) |>
  add_recipe(base_rec_trees)

# tune hyperparameters -----
hardhat::extract_parameter_set_dials(bt_spec)

bt_base_learn_rate <- c(0.09, 0.11)
bt_base_mtry <- c(1, 4)
bt_base_min_n <- c(2, 7)
bt_base_params <- extract_parameter_set_dials(bt_spec) %>%
  update(learn_rate = learn_rate(bt_base_learn_rate)) |>
  update(mtry = mtry(bt_base_mtry)) |>
  update(min_n = mtry(bt_base_min_n))

#write out grid
bt_base_grid <- grid_regular(bt_base_params, levels = 5)
bt_base_grid

# fit workflows/models ----
tuned_bt_base <- tune_grid(bt_base_workflow,
                      clean_folds,
                      grid = bt_base_grid,
                      control = control_grid(save_workflow = TRUE))
tuned_bt_base
stopCluster(cl)
save(tuned_bt_base, file = here("results/tuned_bt_base.rda"))


# testing hyperparameters

autoplot_bt_base <-autoplot(tuned_bt_base, metric = "rmse")
save(autoplot_bt_base, file = here("exploration_results/autoplot_bt_base2.rda"))
autoplot_bt_base

bt_base_rmse <- as_workflow_set(
  bt = tuned_bt_base
)

bt_base_rmse |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  slice_min(mean, by = wflow_id) |>
  arrange(mean) |>
  select(`Model Type` = wflow_id,
         `RMSE` = mean,
         `Standard Error` = std_err,
         `Number of Computations` = n) |>
  knitr::kable(digits = c(NA, 2, 4, 0))


#### Values:
#bt_base_learn_rate <- c(-10,-1)
#bt_base_mtry <- c(1, 4)
#bt_base_min_n <- c(1, 10)
#RMSE = 0.48
#STDERR = 0.0129

#bt_base_learn_rate <- c(-10,-1)
#bt_base_mtry <- c(1, 4)
#bt_base_min_n <- c(2, 40)
#RMSE = 0.48
#STDERR = 0.0112

#bt_base_learn_rate <- c(0.09,0.11)
#bt_base_mtry <- c(1, 4)
#bt_base_min_n <- c(1, 10)
#RMSE = 0.31
#STDERR = 0.0137
#WINNER!!!

#bt_base_learn_rate <- c(0.09,0.11)
#bt_base_mtry <- c(1, 4)
#bt_base_min_n <- c(2, 7)
#RMSE = 0.32
#STDERR = 0.0123

# Finding tuning parameters for the winning model
tuned_bt_base_params <- tuned_bt_base |>
  show_best(
    metric = "rmse") |>
  slice(1) |>
  select(mtry, min_n, learn_rate, .metric, mean, std_err)

tuned_bt_base_params
save(tuned_bt_base_params, file = here("exploration_results/tuned_bt_base_params.rda"))
