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

en_spec <- linear_reg(penalty = tune(), mixture = tune()) |>
  set_engine("glmnet")

# define workflows ----
en_workflow <- workflow() |>
  add_model(en_spec) |>
  add_recipe(rec_main)

# tune hyperparameters -----
hardhat::extract_parameter_set_dials(en_spec)
en_penalty <- c(-8,-2)
en_mixture <- c(0,0.25)
en_params <- extract_parameter_set_dials(en_spec) %>%
  update(mixture = mixture(en_mixture)) |>
  update(penalty = penalty(en_penalty))

#write out grid
en_grid <- grid_regular(en_params, levels = 5)
en_grid

# fit workflows/models ----
tuned_en <- tune_grid(en_workflow,
                           clean_folds,
                           grid = en_grid,
                           control = control_grid(save_workflow = TRUE))
tuned_en
stopCluster(cl)
save(tuned_en, file = here("results/tuned_en.rda"))

autoplot_en <- autoplot(tuned_en, metric = "rmse")
save(autoplot_en, file = here("exploration_results/autoplot_en.rda"))
autoplot_en


# retrieve rmse
en_rmse <- as_workflow_set(
  en = tuned_en
)

en_rmse |>
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
tuned_en_params <- tuned_en |>
  show_best(
    metric = "rmse") |>
  slice(1) |>
  select(penalty, mixture, .metric, mean, std_err)
tuned_en_params

save(tuned_en_params, file = here("exploration_results/tuned_en_params.rda"))


