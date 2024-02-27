library(ggplot2)
library(tidyverse)
library(here)
library(tidymodels)
library(knitr)

# handle common conflicts
tidymodels_prefer()
# load data + recipes
load("results/clean_split.rda")
load("results/clean_folds.rda")
load("results/base_rec_trees.rda")
load("results/base_rec_param.rda")
load("results/null_fit.rda")
load("results/lm_fit.rda")

set.seed(23456)

null_results <- null_fit |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "Null")

lm_results <- lm_fit |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "LM")

lm_null_table <-
bind_rows(lm_results, null_results) |>
  relocate(model, .before = 1) |>
  kable()

lm_null_table
save(lm_null_table, file = here("results/lm_null_table.rda"))
