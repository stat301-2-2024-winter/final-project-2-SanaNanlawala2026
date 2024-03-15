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
load("results/base_rec_main.rda")
load("results/rec_trees.rda")
load("results/rec_main.rda")
load("results/null_fit.rda")
load("results/lm_fit.rda")
load("results/lm_fit_base.rda")
load("results/tuned_bt_base.rda")
load("results/tuned_bt.rda")
load("results/tuned_en_base.rda")
load("results/tuned_en.rda")
load("results/tuned_knn_base.rda")
load("results/tuned_knn.rda")
load("results/tuned_rf_base.rda")
load("results/tuned_rf.rda")



set.seed(23456)

################

null_results <- null_fit |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "Null (base recipe)")

lm_results <- lm_fit |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "LM (feature-engineered recipe)")

lm_base_results <- lm_fit_base |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "LM (base recipe)")

bt_base_results <- tuned_bt_base |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "BT (base recipe)")

rf_base_results <- tuned_rf_base |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "RF (base recipe)")

knn_base_results <- tuned_knn_base |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "KNN (base recipe)")

en_base_results <- tuned_en_base |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "EN (base recipe)")|>
  slice(sample(n(), 1))

en_results <- tuned_en |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "EN (feature-engineered recipe)") |>
  slice(sample(n(), 1))

bt_results <- tuned_bt |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "BT (feature-engineered recipe)")

rf_results <- tuned_rf |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "RF (feature-engineered recipe)")

knn_results <- tuned_knn |>
  show_best("rmse") |>
  slice_min(mean) |>
  mutate(model = "KNN (feature-engineered recipe)")

RMSE_table <-
bind_rows(lm_results, null_results, knn_results, rf_results, bt_results, en_results,
          knn_base_results, rf_base_results, bt_base_results, en_base_results, lm_base_results) |>
  select(model, .metric, .estimator, mean, std_err) |>
  arrange(mean) |>
  rename( `RMSE value` = mean, `Standard Error` = std_err, `Model` = model) |>
  select(Model, `RMSE value`, `Standard Error`) |>
  kable()

RMSE_table
save(RMSE_table, file = here("results/RMSE_table.rda"))
