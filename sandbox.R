library(tidyverse)
library(lubridate)


##' Create sample tibble

my_ratings <- tibble(
  date = c("2021-06-25", "2021-08-01", "2021-10-15"), 
  season = c(1, 3, 2),
  episode = c(1, 4, 4),
  my_rating = c(6,8,9)
)

office_ratings <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-17/office_ratings.csv')

##' do vlookup with tidyquant

install.packages("tidyquant")
my_ratings_with_s_e <- my_ratings %>% 
  mutate(season_episode = paste("s", season, "e", episode, sep = "")) 
office_ratings_with_s_e <- office_ratings %>% 
  mutate(season_episode = paste("s", season, "e", episode, sep = ""))

my_ratings_with_more_info <- my_ratings_with_s_e %>% 
  mutate(title = tidyquant::VLOOKUP(season_episode, office_ratings_with_s_e, season_episode, title),
         air_date = tidyquant::VLOOKUP(season_episode, office_ratings_with_s_e, season_episode, air_date))

##' do vlookup with joins

my_ratings_with_more_info <- left_join(my_ratings, office_ratings)

##' what if I only wanted the title and airdate though

my_ratings_with_more_info <- left_join(my_ratings, office_ratings) %>% 
  select(-imdb_rating, -total_votes)

##' What's different: why do it with joins
##' 1- you can use multiple columns as keys, which in this case comes in handy
##' 2- you often do want more than one column, and the join achieves this with less repetitious code
##' 3- you can use the different joins that are more specifically suited for the usecases that you were using vlooup for. For example, half the time I use a vlookup I'm really only trying to find out which records are on the other table so that I can filter based on that. Once I'm thinking about it as a join I can use semi_joins or anti_joins for a more direct way to get exactly what I need.

##' What's different: things that might be confusing if you're used to matching 'the vlookup way'
##' The example I gave above joins two tables that happened to be very well suited to the join we needed to make, but what if the table I had access to for my title and air_date information wasn't the office_ratings table, but was instead the dataset from the schrute package, which in addition to the information I'm looking for also includes the full transcript of all episodes of The Office?
my_ratings_with_more_info <- left_join(my_ratings, schrute_data)
##' This introduces two issues:
##' One: there are many many more columns than I need, so if I do
##' Two: the same episode appears multiple times in the schrute data, so the join adds rows to my original dataset, although none of those rows contain information relevant to what I need

##' solution: before you join, create a table you're going to use for the join that has the information you need without the information you don't need. In this case:

schrute_data_for_join <- schrute_data %>%
  select(season, episode, title = episode_name, air_date) %>% 
  distinct()

my_ratings_with_more_info <- left_join(my_ratings, schrute_data_for_join)

##some code for nicelooking tables in the slides
knitr::kable(my_ratings_with_more_info, format = "html")
