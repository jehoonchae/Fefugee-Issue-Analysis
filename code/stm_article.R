library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(lubridate) # Make Dealing with Dates a Little Easier
library(quanteda) # Quantitative Analysis of Textual Data
library(stm) # Estimation of the Structural Topic Model
library(stminsights) # A 'Shiny' Application for Inspecting Structural Topic Models
library(tidytext) # Text Mining using 'dplyr', 'ggplot2', and Other Tidy Tools

theme_set(theme_minimal())

df <- read_csv('./data_processed/preprocessed.csv')

df <- df %>%
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

df$date <- ymd(df$date)
min_date <- min(df$date) %>% as.numeric()
df$date_num <- as.numeric(df$date) - min_date
date_table <- df %>% arrange(date_num) %>% select(date, date_num)
# head(date_table, 2)

df %>%
  count(date) %>%
  ggplot(aes(date, n)) +
  # geom_histogram(stat="identity") +
  geom_line() +
  # ggforce::geom_bspline0() +
  scale_x_date(date_breaks = "3 month", date_labels='%Y-%m'
               # , expand=c(0,0.5)
  ) +
  labs(x=NULL, y=NULL)

corpus <- corpus(df, text_field = 'pos', docid_field = 'url')
docvars(corpus)$text <- df$content
docvars(corpus, field='publisher') <- df$publisher
docvars(corpus, field='date') <- df$date
docvars(corpus, field='comment_count') <- df$comment_count
# docvars(corpus, field='comment_count') <- df$comment

# ndoc(corpus) # no. of documents

dfm <- dfm(dfm(corpus,tolower=F,stem=F))
dfm <- dfm_trim(dfm, max_docfreq = .99, min_docfreq = 0.005, docfreq_type = "prop")

out <- convert(dfm, to = "stm")

set.seed(2123)
stm_30 <- stm(documents = out$documents,
              vocab = out$vocab,
              data = out$meta,
              K = 30,
              prevalence = ~ publisher + comment_count + s(date_num),
              verbose = TRUE) # show progress

stm_effects30 <- estimateEffect(1:30 ~ publisher + comment_count + s(date_num),
                                stmobj = stm_30, metadata = out$meta)

# save(out, stm_30, stm_effects30, file = "/Users/jhchae/Dropbox/Pycharm/IC2S2-2020/data/stm_30.RData")

load("/Users/jhchae/Dropbox/Pycharm/IC2S2-2020/data/stm_30.RData")

stm_30_gamma_spread <- tidy(stm_30, matrix='gamma') %>% spread(topic, gamma)
highest_topic <- apply(stm_30_gamma_spread[ ,2:31], 1, which.max)

# stm_30_gamma_spread <- cbind(stm_30_gamma_spread, highest_topic)

# df <- as_tibble(cbind(df, highest_topic))
# df %>% select(url, highest_topic)
# 
# df
# names(df)
# summary(df)
# glimpse(df)

