# Credit ------------------------------------------------------------------

# 99.9% of the code is attributed to @MikeMahoney218 and can be found here:
# https://github.com/mikemahoney218/retweet_bot
# The rest of the 0.1 were some adaptations I did for Hebrew characters
# or removed filters I didn't use.

# Make sure to credit him if you use any of this.


# Code --------------------------------------------------------------------


# Load in filter rules and basic parameters.
# A sample (blanked-out) config file is available in this repo.
source("/home/pi/bot/R/config.R")

library(rtweet)

# for logging a timestamp for influx
options(digits = 19)

# search_strings is defined in config.R -- a vector of
# queries to pull down (in the format "#hashtag -filter:replies")
avail_tweets <- rtweet::search_tweets2(search_strings, include_rts = FALSE)

# read the timestamp from the last run of the script, and write the current
# time, to ensure you only process each tweet once
# if no "last run", just go for the last 5 minutes
last_run <- tryCatch(readLines("~/bot/txt/run_stamp.txt"),
                     error = function(e) {
                      return(Sys.time() - 600)
                     }
)
writeLines(as.character(Sys.time()), "~/bot/run_stamp.txt")

# we'll use the count of hashtags and @ signs as a filtering step later
avail_tweets$nhash <- lengths(regmatches(avail_tweets$text, gregexpr("#", avail_tweets$text)))
avail_tweets$nat <-  lengths(regmatches(avail_tweets$text, gregexpr("@", avail_tweets$text)))

# drop anyone who's being spammy
# Note that permitted is defined in config.R and used to skip checks throughout

too_frequent <- names(table(avail_tweets$user_id)[table(avail_tweets$user_id) > spam_cutoff])
too_frequent_index <- avail_tweets$user_id %in% too_frequent[!(too_frequent %in% permitted)]
not_tweeting_that <- cbind(
  avail_tweets[too_frequent_index, ],
  reason = rep(
    "spam", # these reason codes are used in monitoring
    sum(too_frequent_index)
  )
)
avail_tweets <- avail_tweets[!(too_frequent_index), ]

# filter down to just new tweets
# (since we define spam on the full list retrieved by search_tweets)
avail_tweets <- avail_tweets[avail_tweets$created_at > last_run, ]
not_tweeting_that <- not_tweeting_that[not_tweeting_that$created_at > last_run, ]

# drop the ban list defined in config.R by Twitter IDs
banned_index <- avail_tweets$user_id %in% banlist
not_tweeting_that <- rbind(
  not_tweeting_that,
  cbind(avail_tweets[banned_index, ],
        reason = rep(
          "ban",
          sum(banned_index)
        )
  )
)
avail_tweets <- avail_tweets[!(banned_index), ]

# drop accounts with fewer than a set number of followers (in config.R)
follower_index <- !(avail_tweets$followers_count > follower_cutoff) &
  !(avail_tweets$user_id %in% permitted)
not_tweeting_that <- rbind(
  not_tweeting_that,
  cbind(
    avail_tweets[follower_index, ],
    reason = rep(
      "followers_rule",
      sum(follower_index)
    )
  )
)
avail_tweets <- avail_tweets[!follower_index, ]


# drop people who use too many hashtags (as defined in config.R)
hashtag_index <- (avail_tweets$nhash >= hashtag_cutoff) &
  !(avail_tweets$user_id %in% permitted)
#&  !(avail_tweets$query == "#testinenglish -filter:replies")
not_tweeting_that <- rbind(
  not_tweeting_that,
  cbind(
    avail_tweets[hashtag_index, ],
    reason = rep(
      "hashtags",
      sum(hashtag_index)
    )
  )
)
avail_tweets <- avail_tweets[!(hashtag_index), ]

# drop people who @ too many people
at_index <- (avail_tweets$nat >= at_cutoff) &
  !(avail_tweets$user_id %in% permitted)

not_tweeting_that <- rbind(
  not_tweeting_that,
  cbind(
    avail_tweets[at_index, ],
    reason = rep(
      "atting",
      sum(at_index)
    )
  )
)
avail_tweets <- avail_tweets[!at_index, ]


# prepping for logging -- we want to make sure we log a 0 for each rule
# when it didn't filter any tweets
rule_levels <- c("atting", "spam", "ban", "hashtags", "followers_rule", "source_app", "essay_spam", "probable_essay_spam", "spam_keyword")
rule_table <- table(factor(not_tweeting_that$reason, levels = rule_levels))

# Save output tweets to refine filter rules against
write.table(
  not_tweeting_that[!(sapply(not_tweeting_that, class) == "list")], 
  "~/bot/filtered_tweets.csv", 
  append = TRUE, 
  sep = ",", 
  col.names = FALSE
)
write.table(
  avail_tweets[!(sapply(avail_tweets, class) == "list")], 
  "~/bot/output_tweets.csv", 
  append = TRUE, 
  sep = ",", 
  col.names = FALSE
)

# post the tweets!
if (nrow(avail_tweets) > 0) {
  lapply(avail_tweets$status_id, function(x) rtweet::post_tweet(retweet_id = x))
}

# nice easy validation that the thing is working,
print("Script complete")

# I (Amit) also had the shell script produce a text file for easier logging in the 
# bot's folder.