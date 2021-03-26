library(DBI)
library(rtweet)

con <- dbConnect(drv = RMariaDB::MariaDB(),
                 host = (""), # were uploading from within the pi
                 port = 3306, # port
                 user = "", # user with appropriate privliges
                 password = "", # password
                 dbname = 'twitterbot') # DB name

df_names <- readRDS("~/bot/R/df_names.rds")

# read tables# read tables
filtered = read.delim("~/bot/filtered_tweets.csv", sep = ",", col.names = df_names[["filtered"]])
output = read.delim("~/bot/output_tweets.csv", sep = ",", col.names = df_names[["output"]])

# Get a complete output of the user
history = rtweet::get_timeline("bchirot2021", n = 3200)
history = history[sapply(history, class) != "list"]

# Write tables
dbWriteTable(conn = con, "filtered", filtered, overwrite = TRUE)
dbWriteTable(conn = con, "output", output, overwrite = TRUE)
dbWriteTable(conn = con, "history", history, overwrite = TRUE)


# Disconnect
dbDisconnect(con)
