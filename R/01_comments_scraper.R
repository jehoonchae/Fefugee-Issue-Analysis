# remotes::install_github("forkonlp/DNH4")
# remotes::install_github("forkonlp/N2H4")

# Scrape the comments for NAVER articles

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(readr) # Read Rectangular Text Data
library(lubridate) # Make Dealing with Dates a Little Easier

################################################################################
######################### Scrape comments in Daum News #########################
################################################################################


# 1. NAVER

url_naver <- read_csv('data/raw/naver/url_list_naver.csv', col_names = TRUE)
url_naver$url


# for (i in 1:nrow(url_naver)){
#   url <- url_naver[i, c(1: ncol(url_naver))]$url
#   comments <- as_tibble(N2H4::getAllComment(url))
#   if (nrow(comments) > 0){
#     comments$url <- url
#     comments$portal <- "naver"  
#   }
#   write_csv(x=comments, 
#             path=paste0('../data/comment/naver/comment_naver_', 
#                         sprintf('%05d', i), 
#                         '.csv'))
#   if (i%%1000 == 0){cat(round(i/nrow(url_naver)*100, 2), '% Done', '\n')}
# }

# 2. NAVER

naver_comment_scraper <- function(url){
  comment <- N2H4::getAllComment(url)
  comment$url <- url
  return(comment)
}

# url <- url_naver$url

# output_naver <- lapply(url, function(x) naver_comment_scraper(x)) %>% bind_rows()
write_csv(output_naver, 'data/raw/comment/naver_comment.csv')

# output_naver <- read_csv('./data_raw/comment/naver_comment.csv', col_names = T)
# length(output_naver$url); length(unique(output_naver$url))
# length(output_naver$userIdNo); length(unique(output_naver$userIdNo))

################################################################################
######################### Scrape comments in Daum News #########################
################################################################################

# Call the url list

url_daum <- read_csv('data/raw/url/daum/url_list_daum.csv', col_names = FALSE)
url_daum <- rename(url_daum, "url" = "X1")

# 
# for (i in 18989:nrow(url_daum)){
#   
#   url <- url_daum[i, c(1: ncol(url_daum))]$url
# 
#   tryCatch({
#     comments <- DNH4::getAllComment(url)
#   }, error=function(e) {comments <- NULL})
#   
#   if (is.null(comments)){
#     comments <- data.frame(NULL)
#   }else if (nrow(comments) == 0){
#     comments <- data.frame(NULL)
#   }else if (nrow(comments) == 1){
#     comments <- data.frame(lapply(comments, function(x) t(data.frame(x))))
#     comments$url <- url
#     comments$portal <- "daum"  
#   }else {
#     # comments <- data.frame(lapply(comments, function(x) t(data.frame(x))))
#     comments$url <- url
#     comments$portal <- "daum"    
#   }
#   
#   tryCatch({
#     write_csv(comments, path=paste0('../data/comment/daum/comment_daum_', sprintf('%05d', i), '.csv'))
#   }, error=function(e) {
#     comments <- data.frame(lapply(comments, function(x) t(data.frame(x))))
#     write_csv(comments, path=paste0('../data/comment/daum/comment_daum_', sprintf('%05d', i), '.csv'))
#     })
#   
#   if (i%%1000 == 0){cat(round(i/nrow(url_daum)*100, 2), '% Done', '\n')}
# }

# 2. Daum

# null_df <- data.frame(NULL)
# str_sub(url_daum$url[1], -17, -1)

# daum_comment_scraper <- function(url){
#   cat(url, '\n')
#   error_url <- list()
#   tryCatch({
#     comment <- DNH4::getAllComment(url)
#     comment$url <- url
#     }, error=function(e) {
#       # write_csv(x=null_df,
#       #           path=paste0('./data_raw/uncollected_daum/', str_sub(url,-17,-1)))
#       error_url
#       
#     })
#   return(comment)
# }

scrape_daum_comment <- function(url_list){
  output <- list()  # Initialize with empty list
  for (i in c(1:length(url_list))){ 
    if(i%%1000 == 0){cat(paste0(round(i/length(url_list)*100, 2), '% \n'))}
    tryCatch({
      output[[i]] <- DNH4::getAllComment(url_list[i])
      if(length(output[[i]]) > 1){
        output[[i]]$url <- url_list[i]
      }
    }, error=function(e){
      output[[i]] <- url_list[i]
    })
  }
  return(output)
}

output_daum <- scrape_daum_comment(url_daum$url)

# save(output_daum, file = './data_raw/output_daum_list.RData')
# load(file = './data_raw/output_daum_list.RData')

library(tidyr)

for (i in length(output_daum)){
  tryCatch({
    output_daum[[i]] <- 
      unnest(output_daum[[i]], 
             cols = c(id, postId, forumId, parentId, type, status, flags, content, 
                      createdAt, updatedAt, childCount, likeCount, dislikeCount, 
                      recommendCount, user_id, user_status, user_type, user_flags, 
                      user_username, user_roles, user_providerId, user_providerUserId, 
                      user_displayName, user_commentCount, url))
    }, error = function(e){
    cat(paste0(i,'\n'))
  })
}

library(plyr)
df_daum <- rbind.fill(output_daum)

df_daum <- unnest(df_daum, cols = c(id, postId, forumId, parentId, type, status, flags, content, 
                                    createdAt, updatedAt, childCount, likeCount, dislikeCount, 
                                    recommendCount, user_id, user_status, user_type, user_flags, 
                                    user_username, user_roles, user_providerId, user_providerUserId, 
                                    user_displayName, user_commentCount, url, title))

df_daum <- as_tibble(df_daum)
df_daum <- df_daum %>% select(-title)
# which(df_daum$title %in% unique(df_daum$title)[2:5])
# title_have <- df_daum[which(df_daum$title %in% unique(df_daum$title)[2:5]), 1:ncol(df_daum)]

# glimpse(df_daum)

# save(df_daum, file = './data_raw/output_daum.RData')
# write_csv(df_daum, path = './data_raw/output_daum.csv')
df_daum <- read_csv(file = 'data/raw/output_daum.csv', col_names = TRUE)
summary(df_daum)
df_daum[which(df_daum$user_commentCount < 0), 1:ncol(df_daum)]

