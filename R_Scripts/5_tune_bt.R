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

library(xgboost)

bt_spec <- boost_tree(mode = "regression",
                      min_n = tune(),
                      mtry = tune(),
                      learn_rate = tune()) |>
  set_engine("xgboost")

# define workflows ----
bt_workflow <- workflow() |>
  add_model(bt_spec) |>
  add_recipe(rec_trees)

# tune hyperparameters -----
hardhat::extract_parameter_set_dials(bt_spec)

bt_learn_rate <- c(0.09, 0.11)
bt_mtry <- c(1, 4)
bt_min_n <- c(2, 7)
bt_params <- extract_parameter_set_dials(bt_spec) %>%
  update(learn_rate = learn_rate(bt_learn_rate)) |>
  update(mtry = mtry(bt_mtry)) |>
  update(min_n = mtry(bt_min_n))

#write out grid
bt_grid <- grid_regular(bt_params, levels = 5)

bt_grid

# fit workflows/models ----
tuned_bt <- tune_grid(bt_workflow,
                           clean_folds,
                           grid = bt_grid,
                           control = control_grid(save_workflow = TRUE))
tuned_bt
stopCluster(cl)
save(tuned_bt, file = here("results/tuned_bt.rda"))


# testing hyperparameters

autoplot_bt <-autoplot(tuned_bt, metric = "rmse")
save(autoplot_bt, file = here("exploration_results/autoplot_bt.rda"))
autoplot_bt

bt_rmse <- as_workflow_set(
  bt = tuned_bt
)

bt_rmse |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  slice_min(mean, by = wflow_id) |>
  arrange(mean) |>
  select(`Model Type` = wflow_id,
         `RMSE` = mean,
         `Standard Error` = std_err,
         `Number of Computations` = n) |>
  knitr::kable(digits = c(NA, 2, 4, 0))

# Finding tuning parameters for the winning model
tuned_bt_params <- tuned_bt |>
  show_best(
    metric = "rmse") |>
  slice(1) |>
  select(mtry, min_n, learn_rate, .metric, mean, std_err) |>
  knitr::kable()
tuned_bt_params

save(tuned_bt_params, file = here("exploration_results/tuned_bt_params.rda"))

