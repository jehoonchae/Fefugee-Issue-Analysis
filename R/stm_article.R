library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(quanteda) # Quantitative Analysis of Textual Data
library(stm) # Estimation of the Structural Topic Model
library(stminsights) # A 'Shiny' Application for Inspecting Structural Topic Models
library(tidytext) # Text Mining using 'dplyr', 'ggplot2', and Other Tidy Tools
library(furrr) 

news_naver <- read_csv('data/processed/preprocessed_topic_added.csv', col_names = T)
comment_naver <- read_csv('data/processed/processed_comment_naver.csv', col_names = T)

################################################################################
### Estimating structural topic model with covariates 
################################################################################
df <- news_naver

corpus <- corpus(df, text_field = 'pos', docid_field = 'url')
docvars(corpus)$text <- df$content
docvars(corpus, field='publisher') <- df$publisher
docvars(corpus, field='date') <- df$date
docvars(corpus, field='comment_count') <- df$comment_count
docvars(corpus, field='yemen') <- df$yemen
# docvars(corpus, field='comment_count') <- df$comment

# ndoc(corpus) # no. of documents

dfm <- dfm(dfm(corpus,tolower=F,stem=F))
dfm <- dfm_trim(dfm, max_docfreq = .99, min_docfreq = 0.005, docfreq_type = "prop")

out <- convert(dfm, to = "stm")

# k_seq <- c(10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100)

# topic_number_k <- searchK(documents = out$documents,
#                           vocab = out$vocab,
#                           data = out$meta,
#                           K = k_seq,
#                           heldout.seed = 2123,
#                           cores = 6)

# topic_number_k
# plot.searchK(topic_number_k)
# k_seq_2 <- c(10,20,30,40,50,60,70,80,90,100,120,140,160,180,200,250,300,350,400)
# length(k_seq_2)
# topic_number_k_2 <- searchK(documents = out$documents,
#                             vocab = out$vocab,
#                             data = out$meta,
#                             K = k_seq_2,
#                             heldout.seed = 2123,
#                             cores = 6)

plan(multiprocess)
options(future.globals.maxSize= 891289600)

many_models <- tibble(K = c(20, 30, 40)) %>%
  mutate(topic_model = future_map(K, ~stm(documents = out$documents,
                                          vocab = out$vocab,
                                          data = out$meta,
                                          prevalence = ~ yemen + publisher + comment_count + s(date_num),
                                          max.em.its = 50,
                                          seed = 2123,
                                          K = .,
                                          verbose = TRUE)))

set.seed(2123)
stm_30 <- stm(documents = out$documents,
              vocab = out$vocab,
              data = out$meta,
              K = 30,
              prevalence = ~ yemen + publisher + comment_count + s(date_num),
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


