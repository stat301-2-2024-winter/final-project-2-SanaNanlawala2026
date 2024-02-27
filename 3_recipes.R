library(ggplot2)
library(tidyverse)
library(here)
library(forcats)
library(tidymodels)
library(skimr)

set.seed(222)

# handle common conflicts
tidymodels_prefer()

# load data
load("results/clean_split.rda")
load("results/clean_folds.rda")

skimr::skim(clean_train)



#baseline (kitchen sink)

# Parametrics (lm)
base_rec_param <-
  recipe(score ~ ., data = clean_train) |>
  step_rm(name) |>
  step_dummy(all_nominal_predictors()) |>
  step_center(all_numeric()) |>
  step_scale(all_numeric()) |>
  step_impute_mean(all_predictors())
#  step_interact(~ episodes:duration) |>
#  step_interact(~ ranking:episodes)

# trees non-param (trees)
base_rec_trees <-
  recipe(score ~ ., data = clean_train) |>
  step_rm(name) |>
  step_dummy(all_nominal_predictors(), one_hot = TRUE) |>
  step_center(all_numeric()) |>
  step_scale(all_numeric()) |>
  step_impute_mean(all_predictors())


  #WORKS !!
#prep(base_rec_param) |>
#  bake(new_data = slice_head(clean_train, n = 5))

# Save it all out
save(base_rec_trees, file = here("results/base_rec_trees.rda"))
save(base_rec_param, file = here("results/base_rec_param.rda"))


