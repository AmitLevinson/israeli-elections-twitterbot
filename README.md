# ElectionTwitterbot

This repository outlines my setting up a twitter bot on a raspberry pi with a MySQL database to host the collected data.

As this is still a work on progress, in the meantime here's credit to two individauls which their resources were the stepping stones for this:  

- [Ran Bar Zik's tutorials for setting up a Raspberry pi](https://internet-israel.com/category/%D7%9E%D7%93%D7%A8%D7%99%D7%9B%D7%99%D7%9D/raspberrypi/) Ran makes it very easy and accessible to setup a Raspberry Pi and worth following along if you're interested. Though it's in Hebrew, I'm sure you can find many other relevant tutorials.

- [Mike Mahoney's](https://www.mm218.dev/) GitHub repository containing the [R code for setting up a Twitter bot](https://github.com/mikemahoney218/retweet_bot). Mike's code is fantastic and worth reading even if you don't intend on openning up a Twitter bot. It required some adaptations to Hebrew but other than that it was perfect for setting up the whole process.

I'm always enthusiastic about automating process which led me to write about using [GitHub Actions](https://amitlevinson.com/blog/automated-plot-with-github-actions/) a while back. But I wanted to push my learning of automation a little further, which led me to open buy a Rasppberry Pi.

### Raspberry Pi 4

The whole process runs on a Raspberry Pi 4. If you live in Israel one distributor is [Piitel](https://piitel.co.il/shop/raspberry-pi-4/), where you can find a Raspberry Pi 4 with 2GB Ram for 161 NIS, some $46.

[A good tutorial (in Hebrew)]((https://internet-israel.com/category/%D7%9E%D7%93%D7%A8%D7%99%D7%9B%D7%99%D7%9D/raspberrypi/)) I used was one by Ran Bar-Zik, an Israeli tech reporter and programmer. Just follow along and you should be find. If you interested in an English tutorial I'm sure you can find several online. One talk I liked about the Raspberry pi was ["Using R and a Raspberry Pi to collect social media data""](https://www.youtube.com/watch?v=GyrpODuuzvM), a talk by [Frie Preu](https://frie.codes/) at an R-Ladies Bucharest meetup. 

Once you setup the Raspberry Pi, it's time to move on to setting up the `R` code (or whatever you use).

### R script and Twitter API

#### Configuring the R script and setting up R on the Raspberry Pi

Luckily, majority of the work in terms of setting up the R code for the twitter bot was already public. [Mike Mahoney's](https://www.mm218.dev/) setup a GitHub repository containing [R code for setting up a Twitter bot](https://github.com/mikemahoney218/retweet_bot). Mike's code is fantastic and worth reading even if you don't intend on openning up a Twitter bot. It required some adaptations to Hebrew but other than that it was perfect for setting up the whole process.

Considering the Raspberry Pi doesn't come with R, you have to install it on the machine. It's pretty straight forward and you should be able to get the latest version of R by runnning the following in the terminal:

`sudo apt-get install r-base r-base-core r-base-dev`

Most of the editing and configuring of Mike's code was done on my local machine and copied to the Pi. Once you have R running make sure to install any relevant packages you'll need. The one I needed were `{rtweet}`, `{DBI}` and `{RMySQL}`

#### Twitter API

In terms of the Twitter I setup a new account for the process called [@bchirot2021](https://twitter.com/bchirot2021). In order to work with Twitter's API such as collecting and tweeting tweets, one must setup a [developr account](https://developer.twitter.com/en) and get a correspondeing toekn API to interact with Twitter. When asked about what's the purpose of the API / account state the truth. Provide an explanation of your intentions and be clear what you'll be doing and not doing. Once that was out of the way, save your token and register it on your Raspberry Pi. Michael W. Kearney, the creator of the {rtweet} package for interacting with Twitter in R, has a [great set of slides](https://mkearney.github.io/nicar_tworkshop/#1) on doing so.

### Setting up a MySQL database

To be able to connect to a MySQL database one must first install it on the computer. [Emmet published a great tutorial](https://pimylifeup.com/raspberry-pi-mysql/) on setting a MariaDB, but essentially for MySQL just run the following:

`sudo apt-get install mysql-server`.

Register a root account with a new password, setup a database (`CREATE DATABASE <name>;`), a user (to avoid using root) and provide it with appropriate privileges. However, by default the access is restricted for anyone not on localhost. To open it up you need to edit access privileges. I found editing `/etc/mysql/mariadb.conf.d/50-server.cnf` on the Raspberry pi to solve the issure. Just comment out the `bind-address = 127.0.01` row and restart mysql.

### Wrapping it all together


