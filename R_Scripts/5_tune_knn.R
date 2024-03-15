library(ggplot2)
library(tidyverse)
library(here)
library(tidymodels)
library(doMC)
library(doParallel)
# load data + recipes
load("results/clean_split.rda")
load("results/clean_folds.rda")
load("results/rec_main.rda")

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
knn_workflow <- workflow() |>
  add_model(knn_spec) |>
  add_recipe(rec_main)

# tune hyperparameters -----
hardhat::extract_parameter_set_dials(knn_spec)
knn_neighbors <- c(3, 10)
knn_params <- extract_parameter_set_dials(knn_spec) %>%
  update(neighbors = neighbors(knn_neighbors))

#write out grid
knn_grid <- grid_regular(knn_params, levels = 5)
knn_grid

# fit workflows/models ----
tuned_knn <- tune_grid(knn_workflow,
                            clean_folds,
                            grid = knn_grid,
                            control = control_grid(save_workflow = TRUE))

stopCluster(cl)
save(tuned_knn, file = here("results/tuned_knn.rda"))

autoplot_knn <- autoplot(tuned_knn, metric = "rmse")
autoplot_knn_2 <- autoplot(tuned_knn, metric = "rmse")

save(autoplot_knn, file = here("exploration_results/autoplot_knn_two.rda"))
autoplot_knn_2
save(autoplot_knn_2, file = here("exploration_results/autoplot_knn_2.rda"))

# 1st iteration
#update neighbours to be (1,10)


# retrieve rmse
knn_rmse <- as_workflow_set(
  knn = tuned_knn
)

knn_rmse |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  slice_min(mean, by = wflow_id) |>
  arrange(mean) |>
  select(`Model Type` = wflow_id,
         `RMSE` = mean,
         `Standard Error` = std_err,
         `Number of Computations` = n) |>
  knitr::kable(digits = c(NA, 2, 4, 0))

tuned_knn_params <- tuned_knn|>
  show_best(
    metric = "rmse") |>
  slice(1) |>
  select(neighbors, .metric, mean, std_err)
tuned_knn_params
save(tuned_knn_params, file = here("exploration_results/tuned_knn_params.rda"))

