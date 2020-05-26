library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(lubridate) # Make Dealing with Dates a Little Easier
library(tidyr) # Tidy Messy Data

################################################################################
### Naver news comment data pre-processing ###
################################################################################

# news_daum <- read_csv('./data_raw/article/daum_news_article.csv') %>% select(-X1)
# news_naver <- read_csv('./data_raw/article/naver_news_article.csv')
# comment_daum <- read_csv(file = './data_raw/output_daum.csv', col_names = TRUE)
comment_naver <- read_csv(file = 'data/raw/comment/naver_comment.csv', col_names = TRUE)
# print(comment_naver[5430:5530, 1:ncol(comment_naver)] %>% select(ticket, idType, userIdNo), n = 100)
# unique(comment_naver$ticket)
# nrow(comment_naver)

# > length(unique(comment_naver$idNo)); length(comment_naver$idNo)
# [1] 369431
# [1] 1589803

# Leave comments posted with Naver accounts
comment_naver <- comment_naver %>% 
  filter(ticket == "news") %>% 
  filter(idType == 'naver')

# > length(unique(comment_naver$idNo)); length(comment_naver$idNo)
# [1] 366819
# [1] 1562820

comment_naver <- comment_naver %>% 
  filter(
    regTime > as.Date("2016-12-31"),
    regTime < as.Date("2020-1-1")
  ) %>% 
  mutate(
    year = as.integer(lubridate::year(regTime)),
    month = lubridate::month(regTime, label=TRUE, abbr=TRUE),
    wday = lubridate::wday(regTime, label=TRUE, abbr=TRUE),
    ym = as.Date(format(regTime, "%Y-%m-01")),
    week = lubridate::floor_date(regTime, "week")
  )

comment_naver$date <- ymd(str_sub(comment_naver$regTime, 1, 10))
min_date <- min(comment_naver$date) %>% as.numeric()
comment_naver$date_num <- as.numeric(comment_naver$date) - min_date
comment_naver$week <- ymd(comment_naver$week)
date_table <- comment_naver %>% arrange(date_num) %>% select(date, date_num)

# > length(unique(comment_naver$idNo)); length(comment_naver$idNo)
# [1] 324110
# [1] 1362401

# write_csv(comment_naver, 'data/processed/processed_comment_naver.csv')

################################################################################
### Naver news article data pre-processing ###
################################################################################

news_naver <- read_csv('data/processed/preprocessed.csv')

# > nrow(news_naver)
# [1] 63674

news_naver <- news_naver %>%
  filter(
    date > as.Date("2016-12-31"),  # complete months
    date < as.Date("2020-1-1")
  ) %>%
  mutate(
    year = as.integer(lubridate::year(date)),
    month = lubridate::month(date, label=TRUE, abbr=TRUE),
    wday = lubridate::wday(date, label=TRUE, abbr=TRUE),
    ym = as.Date(format(date, "%Y-%m-01")),
    week = floor_date(date, "week")
  )

news_naver$date <- ymd(news_naver)
min_date <- min(news_naver) %>% as.numeric()
news_naver$date_num <- as.numeric(news_naver$date) - min_date
# date_table <- news_naver %>% arrange(date_num) %>% select(date, date_num)

# > nrow(news_naver)
# [1] 43724

# news_naver <- read_csv('data/processed/preprocessed_topic_added.csv', col_names = T)
# load('data/processed/stm_30.RData')