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

knn_spec <- nearest_neighbor(mode = "regression", neighbors = tune()) |>
  set_engine("kknn")

# define workflows ----
knn_base_workflow <- workflow() |>
  add_model(knn_spec) |>
  add_recipe(base_rec_main)

# tune hyperparameters -----
hardhat::extract_parameter_set_dials(knn_spec)
knn_base_neighbors <- c(3, 10)
knn_base_params <- extract_parameter_set_dials(knn_spec) %>%
  update(neighbors = neighbors(knn_base_neighbors))

#write out grid
knn_base_grid <- grid_regular(knn_base_params, levels = 5)
knn_base_grid

# fit workflows/models ----
tuned_knn_base <- tune_grid(knn_base_workflow,
                           clean_folds,
                           grid = knn_base_grid,
                           control = control_grid(save_workflow = TRUE))

stopCluster(cl)
save(tuned_knn_base, file = here("results/tuned_knn_base.rda"))

autoplot_knn_base <- autoplot(tuned_knn_base, metric = "rmse")
save(autoplot_knn_base, file = here("exploration_results/autoplot_knn_base.rda"))
autoplot_knn_base


# retrieve rmse
knn_base_rmse <- as_workflow_set(
  knn = tuned_knn_base
)

knn_base_rmse |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  slice_min(mean, by = wflow_id) |>
  arrange(mean) |>
  select(`Model Type` = wflow_id,
         `RMSE` = mean,
         `Standard Error` = std_err,
         `Number of Computations` = n) |>
  knitr::kable(digits = c(NA, 2, 4, 0))
# values
#neighbors = (3,10)
# rmse = 0.39 and stderr = 0.0074

tuned_knn_base_params <- tuned_knn_base |>
  show_best(
    metric = "rmse") |>
  slice(1) |>
  select(neighbors, .metric, mean, std_err)
tuned_knn_base_params
save(tuned_knn_base_params, file = here("exploration_results/tuned_knn_base_params.rda"))
