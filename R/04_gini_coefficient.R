library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(broom) # Convert Statistical Analysis Objects into Tidy Tibbles
library(reldist) # Relative Distribution Methods

news_naver <- read_csv('data/processed/preprocessed_topic_added.csv', col_names = T)
comment_naver <- read_csv('data/processed/processed_comment_naver.csv', col_names = T)

###############################################################################
### Gini coefficient by Month ###
###############################################################################

gini_coef_by_month <- comment_naver %>% 
  group_by(ym, userIdNo) %>% 
  summarise(count=n()) %>% 
  group_by(ym) %>% 
  do(tidy(gini(.$count)))

gini_coef_by_month %>% 
  ggplot(aes(ym, x)) +
  geom_line() +
  scale_x_date(date_breaks = "3 month", date_labels='%Y-%m') +
  labs(x=NULL, y=NULL) +
  # theme_test() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

gini_coef_by_week <- comment_naver %>% 
  group_by(week, userIdNo) %>% 
  summarise(count=n()) %>% 
  group_by(week) %>% 
  do(tidy(gini(.$count)))

gini_coef_by_week %>% 
  ggplot(aes(week, x)) +
  geom_line(size=1.5, alpha=.4) +
  geom_point() +
  # stat_smooth(method = loess) +
  scale_x_date(date_breaks = "3 month", date_labels='%Y-%m') +
  labs(x=NULL, y=NULL) +
  # theme_test() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
