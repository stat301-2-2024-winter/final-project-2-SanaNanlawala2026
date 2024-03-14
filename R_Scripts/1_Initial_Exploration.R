library(ggplot2)
library(tidyverse)

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

step_interact(~ episodes:duration) |>
  #  step_interact(~ ranking:episodes)


clean |>
  filter(episodes < 200) |>
  ggplot(aes(x = score, y = episodes)) +
  geom_tile()
