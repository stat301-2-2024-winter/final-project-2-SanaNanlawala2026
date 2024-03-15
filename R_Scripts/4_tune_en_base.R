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

en_spec <- linear_reg(penalty = tune(), mixture = tune()) |>
  set_engine("glmnet")

# define workflows ----
en_base_workflow <- workflow() |>
  add_model(en_spec) |>
  add_recipe(base_rec_main)

# tune hyperparameters -----
hardhat::extract_parameter_set_dials(en_spec)
en_base_penalty <- c(-8,-2)
en_base_mixture <- c(0,0.25)
en_base_params <- extract_parameter_set_dials(en_spec) %>%
  update(mixture = mixture(en_base_mixture)) |>
  update(penalty = penalty(en_base_penalty))

#write out grid
en_base_grid <- grid_regular(en_base_params, levels = 5)
en_base_grid

# fit workflows/models ----
tuned_en_base <- tune_grid(en_base_workflow,
                           clean_folds,
                           grid = en_base_grid,
                           control = control_grid(save_workflow = TRUE))

stopCluster(cl)
save(tuned_en_base, file = here("results/tuned_en_base.rda"))

autoplot_en_base <- autoplot(tuned_en_base, metric = "rmse")
save(autoplot_en_base, file = here("exploration_results/autoplot_en_base2.rda"))
autoplot_en_base


# retrieve rmse
en_base_rmse <- as_workflow_set(
  en = tuned_en_base
)

en_base_rmse |>
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
#en_base_penalty <- c(-10,0)
#en_base_mixture <- c(0,1)
# rmse = 0.69, stderr = 0.0031
# update mixture to be (0,0.25) and penalty to be (-8,-2) which is log transform of 10^-8 and 10^-2

#en_base_penalty <- c(-8,-2)
#en_base_mixture <- c(0,0.25)
# rmse = 0.69, stderr = 0.0031
# no change winning model


# Finding tuning parameters for the winning model
tuned_en_base_params <- tuned_en_base |>
  show_best(
    metric = "rmse") |>
  slice(1) |>
  select(penalty, mixture, .metric, mean, std_err)

tuned_en_base_params
save(tuned_en_base_params, file = here("exploration_results/tuned_en_base_params.rda"))

