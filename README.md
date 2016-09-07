# indeed-scraper
scrape job sites to try and streamline job hunt process

to start you will have to download selenium chrome web driver extension and make sure you have all the neccesary gems installed. Also in your bash profile set two ENV variables for your indeed login.
  -ENV["INDEED_EMAIL"]
  -ENV["INDEED_PASSWORD"]
  
This application is broken into two parts, first the scraping which can be accomplished by running indeed_script.rb. it allows you to enter a search and location in indeed and collects all of the job application data.

once you have that data run runner.rb. It will prompt you to either run easy apply or semi auto apply. you need to run easy apply first which will attempt to apply to all jobs not having a secondary form. After that you can run semi auto which will fill out the beginning of the form and require you to fill in the rest of the information. As you are applying the csv file updates itself for each job posting you apply to.
