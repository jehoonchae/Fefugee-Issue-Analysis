library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(readr) # Read Rectangular Text Data
library(lubridate) # Make Dealing with Dates a Little Easier
library(tidyr) # Tidy Messy Data

################################################################################
### News and comments proportion by week ###
################################################################################
news_naver <- read_csv('data/processed/preprocessed_topic_added.csv', col_names = T)
comment_naver <- read_csv('data/processed/processed_comment_naver.csv', col_names = T)

# news_naver %>% 
#   group_by(date) %>% 
#   summarise(count=n()) %>% 
#   arrange(desc(count)) %>% 
#   head(n=20)
# 
# news_naver$date_num[news_naver$date == '2018-06-19']
# max(news_naver$date_num)
# news_naver$yemen <- ifelse(news_naver$date_num > 534, 1, 0)
# # unique(news_naver$yemen)

comment_week <- 
  comment_naver %>% 
  group_by(week) %>% 
  summarize(count_comment=n()) %>% 
  mutate(prop_week_comment = count_comment/sum(count_comment))

# comment_week %>%
#   ggplot(aes(week, prop_week_comment)) +
#   geom_line() +
#   scale_x_date(date_breaks = "3 month", date_labels='%Y-%m'
#                # , expand=c(0,0.5)
#   ) +
#   labs(x=NULL, y=NULL) +
#   theme_minimal()

news_week <- 
  news_naver %>% 
  group_by(week) %>% 
  summarise(count_news=n()) %>% 
  mutate(prop_week_news = count_news/sum(count_news))

joined_week_df <- full_join(news_week, comment_week, by="week")
joined_week_df <- joined_week_df %>% 
  gather(key = "source_type", value = "prop", prop_week_news, prop_week_comment, 
         -count_comment, -count_news)

joined_week_df %>% 
  ggplot(aes(week, prop)) + 
  geom_line(aes(color = source_type, linetype=source_type), size=.8) +
  scale_color_manual(values = c("red", "black")) +
  scale_linetype_manual(values=c("longdash", "solid")) +
  scale_x_date(date_breaks = "3 month", date_labels='%Y-%m') +
  labs(x=NULL, y="Prevalence ") +
  theme_minimal() +
  # theme_test() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# theme_minimal()

################################################################################
### News and comments proportion by month ###
################################################################################

prop_by_month <- 
  comment_naver %>% 
  group_by(ym) %>% 
  summarize(count=n()) %>% 
  mutate(prop_month = count/sum(count))

prop_by_month %>%
  ggplot(aes(ym, prop_month)) +
  # geom_histogram(stat="identity") +
  geom_line() +
  # ggforce::geom_bspline0() +
  scale_x_date(date_breaks = "3 month", date_labels='%Y-%m'
               # , expand=c(0,0.5)
  ) +
  labs(x=NULL, y=NULL) +
  # theme_bw()
  theme_minimal()

prop_by_month_article <- 
  naver_article %>% 
  group_by(ym) %>% 
  summarise(count_article=n()) %>% 
  mutate(prop_month_article = count_article/sum(count_article))

# sum(prop_by_week_article$prop_week_article)
# sum(prop_by_week$prop_week)

joined_month_df <- full_join(prop_by_month_article, prop_by_month, by="ym")
joined_month_df <- joined_month_df %>% 
  gather(key = "source_type", value = "prop", prop_month_article, prop_month, 
         -count, -count_article)

# Draw a line plot
joined_month_df %>% 
  ggplot(aes(ym, prop)) + 
  geom_line(aes(color = source_type, linetype = source_type), size=.7) +
  scale_color_manual(values = c("darkred", "black")) +
  scale_linetype_manual(values=c("longdash", "solid")) +
  scale_x_date(date_breaks = "3 month", date_labels='%Y-%m') +
  labs(x=NULL, y=NULL) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


