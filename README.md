# Israeli Election Twitterbot




### TL;DR
I set up a Raspberry Pi using [Ran Bar-Zik's](https://internet-israel.com/category/%D7%9E%D7%93%D7%A8%D7%99%D7%9B%D7%99%D7%9D/raspberrypi/) tutorials (in Hebrew) and installed R and MySQL on it. I then implemented [Mike Mahoney's](https://www.mm218.dev/) [R code for setting up a Twitter bot](https://github.com/mikemahoney218/retweet_bot), removing some filters and making sure it works with Hebrew characters. Following that I set up a crontab to run a shell script every 10 minutes. The `.sh` script initiates the entire bot's workflow: Searching for tweets containing the hashtags, filtering them according to some defined parameters, retweeting the valid ones and saving them locally. A month into the project I also set up a script to upload the data to a MySQL database hosted on the Pi which I access from my personal computer.

<p align="center">
<a href="https://twitter.com/bchirot2021/">
<img src="https://github.com/AmitLevinson/israeli-elections-twitterbot/blob/master/bot-img.png?raw=true" width=500 alt="a screenshot of the elections twitterbot">
</a>
</p>

### Introduction

This repository outlines my setting up a twitter bot on a raspberry pi with a MySQL database to host the collected data.

**Lots of credit goes to two individuals who were invalauable resources for setting this up:**  

- [Mike Mahoney's](https://www.mm218.dev/) GitHub repository containing the [R code for setting up a Twitter bot](https://github.com/mikemahoney218/retweet_bot). Mike's code is fantastic and worth reading even if you don't intend to open up a Twitter bot. It required some adaptations to Hebrew but other than that it was perfect for setting up the whole process.

- [Ran Bar Zik's tutorials for setting up a Raspberry pi](https://internet-israel.com/category/%D7%9E%D7%93%D7%A8%D7%99%D7%9B%D7%99%D7%9D/raspberrypi/) Ran makes it very easy and accessible to setup a Raspberry Pi and worth following along if you're interested. Though it's in Hebrew, I'm sure you can find many other relevant tutorials.

I'm always enthusiastic about automating processes, which led me to write about using [GitHub Actions](https://amitlevinson.com/blog/automated-plot-with-github-actions/) a while back. But I wanted to push my learning of automation a little further, which led me to buy a Rasppberry Pi. Read on to learn more about the various components in the Bot's workflow.

### Raspberry Pi 4

The whole workflow runs on a [Raspberry Pi 4](https://www.raspberrypi.org/), a 'small single-board computer'. If you live in Israel one distributor is [Piitel](https://piitel.co.il/shop/raspberry-pi-4/) where you can find a Pi 4 with 2GB Ram for 161 NIS, approximately $46.

[A good tutorial (in Hebrew)]((https://internet-israel.com/category/%D7%9E%D7%93%D7%A8%D7%99%D7%9B%D7%99%D7%9D/raspberrypi/)) I used for setting up the Pi is one by Ran Bar-Zik, an Israeli tech reporter and programmer. Just follow along and you should be fine. A talk I enjoyed about things you can do with R and a Raspberry pi is ["Using R and a Raspberry Pi to collect social media data""](https://www.youtube.com/watch?v=GyrpODuuzvM) by [Frie Preu](https://frie.codes/) at an R-Ladies Bucharest meetup. Make sure to check it out!

Once you setup the Raspberry Pi (Install a Debian or some operating system, enable `ssh` access, etc.), it's time to set up `R` and the code for the Bot.

### R script and Twitter API

#### Configuring the R script and setting up R on the Raspberry Pi

Luckily, the majority of the work in terms of setting up a twitter bot using R was already shared online. [Mike Mahoney](https://www.mm218.dev/) set up a GitHub repository containing the [R code for setting up a Twitter bot](https://github.com/mikemahoney218/retweet_bot). Mike's code is fantastic and worth reading even if you don't intend to open up a Twitter bot. It required some adaptations to Hebrew but other than that it was perfect for setting up the whole process.

Considering the Raspberry Pi doesn't come with R, you have to first install it on the Pi itself. It's pretty straight forward and you should be able to get the latest version of R by running the following in the terminal:

`sudo apt-get install r-base r-base-core r-base-dev`

I did most of the editing and configuring of Mike's code on my computer and then copied the files to the Pi. Once you have R running make sure to install any relevant packages you'll need. The ones I required were: `{rtweet}`, `{DBI}` and `{RMySQL}` (which install further dependencies).

#### Twitter API

I set up a new account for the bot called [@bchirot2021](https://twitter.com/bchirot2021). In order to work with Twitter's API, e.g., collecting and tweeting tweets, one must set up a [developer's account](https://developer.twitter.com/en) and get a corresponding API token to interact with Twitter. When asked about what's the purpose of the API / account, state the truth. Provide an explanation of your intentions and be clear what you'll be doing and not doing. Once that's out of the way, save your token and register it on your Raspberry Pi. [Michael W. Kearney](https://mikewk.com/), the creator of the {rtweet} package for interacting with Twitter in R, has a [great set of slides](https://mkearney.github.io/nicar_tworkshop/#1) on doing so.

### Setting up a MySQL database

To be able to connect to a MySQL database (e.g. if you want to store the outputted and filtered tweets) one must first install it on the pi. [Emmet published a great tutorial](https://pimylifeup.com/raspberry-pi-mysql/) on setting a MariaDB, but essentially for MySQL just run the following:

`sudo apt-get install mysql-server`.

Register a root account with a new password, setup a database, a user - in order to avoid using root - and provide it with appropriate privileges. However, by default the access to any database on the Pi (at least to me) is restricted for anyone not on localhost. To open the access you need to edit access privileges. I found editing `/etc/mysql/mariadb.conf.d/50-server.cnf` on the Raspberry Pi to solve the issue. Just comment out the `bind-address = 127.0.01` row and restart MySQL.

### Wrapping it all together

Once all files are in place just set up a shell script to run your `retweet_bot.R` file every 10 minutes, and have the script run by a crontab you set up. The `R/retweet_bot.R` file runs the `R/config.R` file, filters any spam and retweets the relevant tweets. It then appends the outputted and filtered tweets to separate `.csv` files (not shared here). Unfortunately I should have done better tests before starting as the files aren't saved properly, e.g. some columns spill over to other columns, etc. Instead I use the `R/bot-db.R` that queries the @bchirot user's tweet history everyday at 23:00. I also use the `R/df_names.rds` file to properly name the table's names for when I upload the collected data to the MySQL database. 

Both shell scripts - That which runs the bot every 10 minutes and the one for updating the database at 23:00 - produce a 'log'. I have them save a text file (`.txt`) which records the last time it was run. Both of these are found in the `txt` folder, and on my Pi help me know when they last ran (since it shows the date of when it was last modified). You could use 

The MySQL database wasn't necessary for this project, I just set it up so I can practice my SQL querying skills. Also, in retrospect if I saw this as a long term project with a lot more data I would normalize the database better. That is, now each table contains nearly 90 columns, and instead we could split it up to several tables, add any relevant keys, constaints, etc. Maybe next time around.

Hopefully some of this was helpful; it sure was a great experience for me. 

**Feel free to reach out if you have any questions and I can be of any help!**
