library(ggplot2)
library(tidyverse)
library(here)
library(tidymodels)

# handle common conflicts
tidymodels_prefer()
# load data + recipes
load("results/clean_split.rda")
load("results/clean_folds.rda")
load("results/base_rec_main.rda")

set.seed(23456)
# model specifications ----
lm_spec <-
  linear_reg() |>
  set_engine("lm") |>
  set_mode("regression")

# define workflows ----
lm_wflow <- workflow()  |>
  add_model(lm_spec) |>
  add_recipe(base_rec_main)

lm_wflow

# fit workflows/models ----
lm_fit_base <- lm_wflow %>%
  fit_resamples(
    resamples = clean_folds,
    control = control_resamples(save_workflow = TRUE)
  )
lm_fit_base


lm_base_rmse <- as_workflow_set(
  lm = lm_fit_base
)


lm_base_rmse |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  slice_min(mean, by = wflow_id) |>
  arrange(mean) |>
  select(`Model Type` = wflow_id,
         `RMSE` = mean,
         `Standard Error` = std_err,
         `Number of Computations` = n) |>
  knitr::kable(digits = c(NA, 2, 4, 0))


# write out results (fitted/trained workflows) ----
save(lm_fit_base, file = here("results/lm_fit_base.rda"))

