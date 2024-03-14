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



# Kitchen Sink Main:

# Parametrics (lm)
base_rec_main <-
  recipe(score ~ ., data = clean_train) |>
  step_rm(name) |>
  step_dummy(all_nominal_predictors()) |>
  step_center(all_numeric()) |>
  step_scale(all_numeric()) |>
  step_impute_mean(all_predictors())
#  step_interact(~ episodes:duration) |>
#  step_interact(~ ranking:episodes)


# Kitchen Sink Trees:
# trees non-param (trees)
base_rec_trees <-
  recipe(score ~ ., data = clean_train) |>
  step_rm(name) |>
  step_dummy(all_nominal_predictors(), one_hot = TRUE) |>
  step_center(all_numeric()) |>
  step_scale(all_numeric()) |>
  step_impute_mean(all_predictors())

#prep(base_rec_trees) |>
#  bake(new_data = slice_head(clean_train, n = 5))


# Main Complex:
rec_main <-
  recipe(score ~ ., data = clean_train) |>
  step_rm(name) |>
  step_dummy(all_nominal_predictors()) |>
  step_center(all_numeric()) |>
  step_scale(all_numeric()) |>
  step_impute_mean(all_predictors()) |>
  step_interact(~ ranking:duration) |>
  step_interact(~ ranking:score) |>
  step_interact(~ duration:score)
# Trees Complex:
rec_trees <-
  recipe(score ~ ., data = clean_train) |>
  step_rm(name) |>
  step_dummy(all_nominal_predictors(), one_hot = TRUE) |>
  step_center(all_numeric()) |>
  step_scale(all_numeric()) |>
  step_impute_mean(all_predictors())|>
  step_interact(~ ranking:duration) |>
  step_interact(~ ranking:score) |>
  step_interact(~ duration:score)




# Save it all out
save(base_rec_trees, file = here("results/base_rec_trees.rda"))
save(base_rec_main, file = here("results/base_rec_main.rda"))
save(rec_main, file = here("results/rec_main.rda"))
save(rec_trees, file = here("results/rec_trees.rda"))


