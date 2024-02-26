library(ggplot2)
library(tidyverse)
library(here)
library(forcats)

anime <- read_csv("data/anime-filtered.csv")

#Selecting variables and only episodic animes
adjust <- anime |>
  select(Name, Score, Type, Episodes, Source, Rating, Ranked, Duration) |>
  filter(Type == "TV" | Type == "ONA" | Type == "OVA" | Type == "Special")

#turning Duration into just the number of minutes
adjust <- adjust |>
  mutate(Duration = str_replace(Duration, " min\\. per ep\\.$", ""),
         Duration = str_replace(Duration, " min\\.$", ""))

#Turning Unknowns in NAs
adjust <- adjust |>
  mutate(duration = ifelse(Duration == "Unknown", NA, Duration),
         episodes = ifelse(Episodes == "Unknown", NA, Episodes),
         )

#Binary Predictors for Ratings
adjust <- adjust |>
  mutate(PG_13 = ifelse(Rating == "PG-13 - Teens 13 or older", 1, 0),
       R = ifelse(Rating == "R - 17+ (violence & profanity)", 1, 0),
       PG = ifelse(Rating == "PG - Children", 1, 0),
       R_plus = ifelse(Rating == "R+ - Mild Nudity", 1, 0),
       G = ifelse(Rating == "G - All Ages", 1, 0),
       Rx = ifelse(Rating == "Rx - Hentai", 1, 0))
unique(anime$Source)

#Turning Source into Binary Predictors
adjust <- adjust |>
  mutate(manga = case_when(Source == "Manga" | Source == "Web manga" | Source == "Digital manga"
                           | Source == "4-koma manga"
                           ~ 1, TRUE ~ 0),
         book = case_when(Source == "Light novel" | Source == "Visual novel" | Source == "Novel"
                           | Source == "Novel" |Source == "Picture book" |
                            Source == "Book"
                           ~ 1, TRUE ~ 0),
         music = case_when(Source == "Music" | Source == "Radio"
                           ~ 1, TRUE ~ 0),
         game = case_when(Source == "Game" | Source == "Card Game"
                           ~ 1, TRUE ~ 0),
         other = ifelse(Source == "Other", 1, 0),
         original = ifelse(Source == "Original", 1, 0)
  )

# making all needed variables lowercase
adjust <- adjust |>
  mutate(name = Name,
         score = Score,
         ranking = as.numeric(Ranked),
         type = Type,
         episodes = as.numeric(episodes),
         duration = as.numeric(duration))



#cleaned dataset
clean <- adjust |>
  filter(Rx == 0) |>
  select(name, score, type, episodes, ranking, duration, PG_13, R, PG, R_plus, G, manga, book, music, game, other, original)

#writing out cleaned dataset
write_csv(clean,"data/clean.csv")
