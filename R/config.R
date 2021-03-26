# All code and further explanations can be found at @XXX GitHub repo
# with his original code

acct_name <- "bchirot2021"

# Any tweets matching strings in here are fair game for retweeting
# Were interested in all tweets that are not replies so use the format:
# #hashtag -filter:replies
search_strings <- c(
  "#בחירות -filter:replies"
)

# List of user IDs to never, ever retweet
banlist <- c(
  
)

# List of user IDs who are exempt from all checks
permitted <- c(
  
  )

# List of tweet sources to filter out
# There are some specific enterprise softwares with twitter integrations
# whose users are generally pretty spammy
banned_sources <- c(
  
)

# Numeric cutoffs for annoying behaviors
# These values effectively set the checks to "off" 
spam_cutoff <- 9999
follower_cutoff <- -1
hashtag_cutoff <- 281
at_cutoff <- 281
newline_n <- 281
