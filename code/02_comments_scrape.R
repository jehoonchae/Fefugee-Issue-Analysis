# remotes::install_github("forkonlp/DNH4")
# remotes::install_github("forkonlp/N2H4")

# Scrape the comments for NAVER articles

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(readr) # Read Rectangular Text Data
library(lubridate) # Make Dealing with Dates a Little Easier

url_naver <- read_csv('data_raw/url/naver/url_list_naver.csv', col_names = TRUE)

# Scrape comments in Naver News

for (i in 1:nrow(url_naver)){
  url <- url_naver[i, c(1: ncol(url_naver))]$url
  comments <- as_tibble(N2H4::getAllComment(url))
  if (nrow(comments) > 0){
    comments$url <- url
    comments$portal <- "naver"  
  }
  write_csv(x=comments, path=paste0('../data/comment/naver/comment_naver_', sprintf('%05d', i), '.csv'))
  if (i%%1000 == 0){cat(round(i/nrow(url_naver)*100, 2), '% Done', '\n')}
}

# Scrape comments in Daum News

# Call the url list

url_daum <- read_csv('data_raw/url/daum/url_list_daum.csv', col_names = FALSE)
url_daum <- rename(url_daum, "url" = "X1")

for (i in 18989:nrow(url_daum)){
  
  url <- url_daum[i, c(1: ncol(url_daum))]$url

  tryCatch({
    comments <- DNH4::getAllComment(url)
  }, error=function(e) {comments <- NULL})
  
  if (is.null(comments)){
    comments <- data.frame(NULL)
  }else if (nrow(comments) == 0){
    comments <- data.frame(NULL)
  }else if (nrow(comments) == 1){
    comments <- data.frame(lapply(comments, function(x) t(data.frame(x))))
    comments$url <- url
    comments$portal <- "daum"  
  }else {
    # comments <- data.frame(lapply(comments, function(x) t(data.frame(x))))
    comments$url <- url
    comments$portal <- "daum"    
  }
  
  tryCatch({
    write_csv(comments, path=paste0('../data/comment/daum/comment_daum_', sprintf('%05d', i), '.csv'))
  }, error=function(e) {
    comments <- data.frame(lapply(comments, function(x) t(data.frame(x))))
    write_csv(comments, path=paste0('../data/comment/daum/comment_daum_', sprintf('%05d', i), '.csv'))
    })
  
  if (i%%1000 == 0){cat(round(i/nrow(url_daum)*100, 2), '% Done', '\n')}
}
