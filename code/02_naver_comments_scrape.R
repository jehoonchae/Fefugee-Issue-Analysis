# remotes::install_github("forkonlp/DNH4")
# library(DNH4)
# library(tidyverse)
# comments_daum <- DNH4::getAllComment("http://v.media.daum.net/v/20180513202105651")
# comments_daum <- as_tibble(comments_daum)
# glimpse(comments_daum)
# remotes::install_github("forkonlp/N2H4")

# Scrape the comments for NAVER articles
library(tidyverse)
library(readr)
library(lubridate)

url_naver <- read_csv('data/url/naver/url_list.csv', col_names = TRUE)

# # If date NA fill
# for (i in 1:nrow(url_naver)){
#   if (is.na(url_naver[i, c(1: ncol(url_naver))]$date) != FALSE){
#     url_naver[i, c(1: ncol(url_naver))]$date <- url_naver[i-1, c(1: ncol(url_naver))]$date
#     print(i)
#   }
# }

# Scrape comments in Naver News
for (i in 1:nrow(url_naver)){
  url <- url_naver[i, c(1: ncol(url_naver))]$url
  comments <- as_tibble(N2H4::getAllComment(url))
  if (nrow(comments) > 0){
    comments$url <- url
    comments$portal <- "naver"  
  }
  write_csv(x=comments, path=paste0('data/comment/naver/comment_naver_', sprintf('%05d', i), '.csv'))
  if (i%%1000 == 0){cat(round(i/nrow(url_naver)*100, 2), '% Done', '\n')}
}

# files = list.files('data/comment/naver', pattern="*.csv")
# sort(files)
# data_list = lapply(files, read.table, header = TRUE)
# df <- do.call(rbind, data_list)
