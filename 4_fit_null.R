library(ggplot2)
library(tidyverse)
library(here)
library(tidymodels)
library(doMC)
library(doParallel)
# load data + recipes
load("results/clean_split.rda")
load("results/clean_folds.rda")
load("results/base_rec_trees.rda")
load("results/base_rec_param.rda")

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
null_spec <- null_model() %>%
  set_engine("parsnip") %>%
  set_mode("regression") # or set_mode("classification")

null_workflow <- workflow() %>%
  add_model(null_spec) %>%
  add_recipe(base_rec_trees)

null_workflow

null_fit <- null_workflow %>%
  fit_resamples(
    resamples = clean_folds,
    control = control_resamples(save_workflow = TRUE)
  )
#keep_pred <- control_resamples(save_pred = TRUE)
#fit_folds_null <- fit_resamples(null_workflow, resamples = clean_folds, control = control_resamples(save_pred = TRUE))
#fit_folds_null

save(null_fit, file = here("results/null_fit.rda"))
save(fit_folds_null, file = here("results/fit_folds_null.rda"))

