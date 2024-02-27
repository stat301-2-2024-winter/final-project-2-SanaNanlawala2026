library(ggplot2)
library(tidyverse)
library(here)
library(tidymodels)

# load data + recipes
load("results/clean_split.rda")
load("results/clean_folds.rda")
load("results/base_rec_trees.rda")
load("results/base_rec_param.rda")

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

#trees don't have to be tuned
#(set it big enough that it doesn't make a difference)

# define workflows ----
rf_workflow <- workflow() |>
  add_model(rf_model) |>
  add_recipe(recipe)

# hyperparameter tuning values ----

rf_params <- extract_parameter_set_dials(rf_model) |>
  update(mtry = mtry(range = c(1, 14)))

rf_grid <- grid_regular(rf_params, levels = 5)
rf_grid


# fit workflows/models ----
tuned_rf <- tune_grid(rf_workflow,
                      carseats_fold,
                      grid = rf_grid,
                      control = control_grid(save_workflow = TRUE))
#control grid bc control grid not fit resample
stopCluster(cl)

# write out results (fitted/trained workflows) ----

save(tuned_rf, file = here("results/tuned_rf.rda"))
save(rf_workflow, file = here("results/rf_workflow.rda"))
save(rf_grid, file = here("results/rf_grid.rda"))

# tuning for bt, knn, rf, lasso/ridge (tune penalty for last two)
