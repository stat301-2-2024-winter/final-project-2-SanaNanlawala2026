library(ggplot2)
library(tidyverse)
library(here)
library(forcats)
library(tidymodels)

set.seed(22)

# handle common conflicts
tidymodels_prefer()

clean <- read_csv("data/clean.csv")
unique(clean$type)

#split the data
clean_split <- clean |>
  initial_split(strata = score, prop = 0.7)

clean_train <- clean_split |>
  training()

clean_test <- clean_split |>
  testing()

clean_folds <- vfold_cv(clean_train, v = 5, repeats = 3, strata = score)
save(clean_train, clean_test, file = "results/clean_split.rda")
save(clean_train, file = "results/clean_train.rda")
save(clean_test, file = "results/clean_test.rda")
save(clean_folds, file = "results/clean_folds.rda")
