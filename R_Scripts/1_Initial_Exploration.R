library(ggplot2)
library(tidyverse)
library(naniar)

anime <- read_csv("data/anime-filtered.csv")
clean <- read_csv("data/clean.csv")
unique(clean$type)



clean |>
  filter(score != 6.51) |>
  ggplot(aes(score))+
  geom_histogram()


clean |>
  filter(episodes < 70) |>
  ggplot(aes(episodes))+
  geom_histogram()


clean |>
  filter() |>
  ggplot(aes(episodes))+
  geom_histogram()


unique(clean$type)

clean |>
  filter(episodes < 100) |>
  ggplot(aes(y = score, x = episodes))+
  geom_point()

clean |>
  ggplot(aes(ranking))+
  geom_bar()

clean |>
  filter(type == "TV" ) |>
  filter(episodes < 100) |>
  ggplot(aes(x = duration, y = score))+
  geom_point()

clean |>
  ggplot(aes(x = score, y = ranking))+
  geom_jitter()

clean |>
  na.omit(clean) |>
  cor(clean$duration, clean$score)

cor(clean[complete.cases(clean), "ranking"], clean[complete.cases(clean), "episodes"])

cor(clean[complete.cases(clean), "duration"], clean[complete.cases(clean), "ranking"])


missingness_plot <- clean |>
  select(episodes, ranking, duration) |>
  vis_miss() +
  labs(title = "Missingness in Data", x = "Variables")

missingness_plot
save(missingness_plot, file = here("exploration_results/missingness_plot.rda"))

initial_score_exploration <- clean |>
  ggplot(aes(score))+
  geom_histogram() +
  labs(title = "Preliminary Exploration of Target Distribution (Score) ")
initial_score_exploration
save(initial_score_exploration, file = here("exploration_results/initial_score_exploration.rda"))


second_score_exploration <- clean |>
  filter(score != 6.51) |>
  ggplot(aes(score))+
  geom_histogram() +
  labs(title = "Closer Exploration of Target Distribution (Score)")
second_score_exploration
save(second_score_exploration, file = here("exploration_results/second_score_exploration.rda"))

clean |>
  filter(episodes < 200) |>
  ggplot(aes(x = score, y = episodes)) +
  geom_tile()
