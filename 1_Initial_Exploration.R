library(ggplot2)
library(tidyverse)

anime <- read_csv("data/anime-filtered.csv")


anime |>
  filter(Score != 6.51) |>
  ggplot(aes(Score))+
  geom_bar()
