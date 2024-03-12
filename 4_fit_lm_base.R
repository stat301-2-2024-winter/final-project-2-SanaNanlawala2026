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
  add_recipe(base_rec_param)

lm_wflow
lm_fit <- lm_wflow %>%
  fit_resamples(
    resamples = clean_folds,
    control = control_resamples(save_workflow = TRUE)
  )

# fit workflows/models ----
keep_pred <- control_resamples(save_pred = TRUE)
fit_folds_lm <- fit_resamples(lm_wflow, resamples = clean_folds, control = keep_pred)

# write out results (fitted/trained workflows) ----
save(lm_fit, file = here("results/null_fit.rda"))
save(fit_folds_lm, file = "results/fit_folds_lm.rda")

