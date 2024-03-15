library(ggplot2)
library(tidyverse)
library(here)
library(tidymodels)
library(doMC)
library(doParallel)
library(knitr)
load(here("results/final_predict.rda"))
load("results/clean_test.rda")
load(here("results/final_fit.rda"))

prediction_comparison <- bind_cols(clean_test, final_predict) |>
  select(score, .pred)

rmse_value <- rmse(prediction_comparison, truth = score, estimate = .pred)
mae_value <- mae(prediction_comparison, truth = score, estimate = .pred)
rsq_value <- rsq(prediction_comparison, truth = score, estimate = .pred)
rmse_value
mae_value
rsq_value
# make table

evaluation_table <- bind_rows(
  rmse_value %>% mutate(Metric = "RMSE"),
  mae_value %>% mutate(Metric = "MAE"),
  rsq_value %>% mutate(Metric = "R-Squared")
) |>
  rename("Performance Metric" = .metric,
         "Value" = `.estimate`) |>
  select(`Performance Metric`, `Value`) |>
  kable()
evaluation_table
save(evaluation_table, file = here("results/evaluation_table.rda"))
