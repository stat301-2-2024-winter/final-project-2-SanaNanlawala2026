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

model_results <- as_workflow_set(
  bt = tuned_bt,
  rf = tuned_rf,
  knn = tuned_knn,
  en = tuned_en,
  null = null_fit,
  lm = lm_fit,
  baseline_lm = lm_fit_base,
  bt_base = tuned_bt_base,
  rf_base = tuned_rf_base,
  knn_base = tuned_knn_base,
  en_base = tuned_en_base,
  )

model_results <- model_results |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  slice_min(mean, by = wflow_id) |>
  arrange(mean) |>
  select(`Model Type` = wflow_id,
         `RMSE` = mean,
         `Standard Error` = std_err) |>
  knitr::kable()
model_results



################

null_results <- null_fit |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "Null (base recipe)")

lm_results <- lm_fit |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "LM (feature-engineered recipe)")

lm_base_results <- lm_fit_base |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "LM (base recipe)")

bt_base_results <- tuned_bt_base |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "BT (base recipe)")

rf_base_results <- tuned_rf_base |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "RF (base recipe)")

knn_base_results <- tuned_knn_base |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "KNN (base recipe)")

en_base_results <- tuned_en_base |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "EN (base recipe)")

en_results <- tuned_en |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "EN (feature-engineered recipe)")

bt_results <- tuned_bt |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "BT (feature-engineered recipe)")

rf_results <- tuned_rf |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "RF (feature-engineered recipe)")

knn_results <- tuned_knn |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  mutate(model = "KNN (feature-engineered recipe)")
knn_results
RMSE_table <-
bind_rows(lm_results, null_results, knn_results, rf_results, bt_results, en_results,
          knn_base_results, rf_base_results, bt_base_results, en_base_results, lm_base_results) |>
  select(model, .metric, .estimator, mean, std_err) |>
  kable()

RMSE_table
save(lm_null_table, file = here("results/lm_null_table.rda"))
