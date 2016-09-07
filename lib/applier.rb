require 'selenium-webdriver'
require 'pry'
require 'nokogiri'

require_relative 'jobs'

class Applier

  attr_accessor :driver, :jobs

  def initialize
    @driver = Selenium::WebDriver.for:chrome
    @jobs = Jobs.new({filename: "jobs.csv", driver: @driver })
  end

  def easy_apply_run
    login_to_indeed
    self.jobs.apply_easy_jobs
  end

  def mostly_easy_apply_run
    login_to_indeed
    self.jobs.mostly_easy_apply_jobs
  end

  def login_to_indeed
    @driver.navigate.to("http://www.indeed.com")
    sleep 1
    @driver.find_elements(id: "userOptionsLabel")[0].click
    sleep 1
    @driver.find_element(id: "signin_password").send_keys(ENV["INDEED_PASSWORD"])
    @driver.find_element(id: "signin_email").send_keys(ENV["INDEED_EMAIL"])
    sleep 4
  end

end
