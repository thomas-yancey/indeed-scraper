require 'selenium-webdriver'
require 'pry'
require 'csv'
require 'nokogiri'


def print_cover_letter(el)

  return "To Whom it may concern,

With my skill set and experience, I believe I would make a great addition to the #{el[3]} team. I have experience with multiple web technologies, including Ruby on Rails, Javascript, React.js, PostgreSQL, responsive frameworks like Bootstrap and Semantic UI, and behavior driven development frameworks like Jasmine and RSpec. I have built a number of passion projects using these technologies, including www.brokeflix.com, a free streaming movie aggregator that makes it easy to find quality free movies online. The app was built using Ruby on Rails 5 api mode backend, and a React.js frontend configured with Webpack.

Whether it’s a team project or my personal website (www.tomyancey.me), I always insist on a high level of quality and stability.

For all of the reasons above, I believe I would make a great addition to your team. I have attached my resume for your consideration and look forward to hearing from you.

Best Regards,
Thomas Yancey"
end


def recruiter_letter
  return "To Whom it may concern,

With my skill set and experience, I believe I would make a great addition to your client's team. I have experience with multiple web technologies, including Ruby on Rails, Javascript, HTML5, CSS3, React.js, PostgreSQL, responsive frameworks like Bootstrap and Semantic UI, and behavior driven development frameworks like Jasmine and RSpec. I have built a number of passion projects using these technologies, including CitiBike Map, a live station feed map of New York City CitiBike locations. The app was built using Ruby on Rails, a vanilla Javascript MVC frontend, and the Google Maps API.

Whether it’s a team project or my personal site(www.tomyancey.me) or blog (blog.tomyancey.me), I always insist on a high level of quality and stability.

For all of the reasons above, I believe I would make a great addition to your client's team. I have attached my resume for your consideration and look forward to hearing from you.

Best Regards,
Thomas Yancey"
end

def cover_letter_to_clipboard(el)
  `echo "#{print_cover_letter(el)}" | pbcopy`
end

def recruiter_to_clipboard
  `echo "#{recruiter_letter}" | pbcopy`
end

def file_path_to_clipboard(el)
  `echo "/Users/thomasyancey/Desktop/indeed-apply/cover_letters/#{el[0]}" | pbcopy`
end

def loop_through_jobs(arr)
  arr[1..-1].each_with_index do |el,i|
    index = i + 1

#     next if el[0] != "p_388abe5fd14f2f6a" #id
#     next if el[3] != "Real Life Sciences"
    # next if el[5] != "false" # easy_apply
        puts i
    # next if !el[1].downcase.match(/ruby|junior|jr|rails|stack/)
    # next if el[6] == "30 days ago" || el[6] == "30+ days ago"
    # next if el[7] != "frontend developer" #Job search
    # # next if el[8] != "Phoenix az" # #search location

    next if el[9] == "true" || el[9] == "TRUE" #for viewed
    next if el[10] == "true" || el[10] == "TRUE" #for applied
    next if el[-2] == "true" || el[-2] == "TRUE" #skip


    cover_letter_to_clipboard(el)

    # %x{ open cover_letters/#{el[0]} }
    navigate_with_rescue_if_closed(el)

    input = user_applied_response(el)
    break if input == "done"
    # set viewed to true
    arr[index][9] = "true"
    #set applied to true or false
    arr[index][10] = input == "y" ? "true" : "false"
    # set timestamp if applied
    arr[index][11] = Time.now.strftime("%d/%m/%Y %H:%M") if input == "y"

  end
end

def run_program
  arr = CSV.table("jobs.csv").to_a

  # receiving a "undefined method encode for nil" error? replace above line with:

  # arr = CSV.read( "jobs.csv", { headers:           false,
  #               converters:        :numeric,
  #               header_converters: :symbol } ).to_a


  done = false

  @driver = Selenium::WebDriver.for:chrome

  selection = ""
  until selection == "all" || selection == "easy"
    puts "all or easy"
    selection = gets.chomp
  end

  if selection == "all"
    loop_through_jobs(arr)
  else
    easy_apply_run(arr)
  end

  @driver.quit

  CSV.open("out.csv", 'w') do |csv|
    arr.each{|line| csv << line }
  end
  `mv jobs.csv last_run.csv`
  `mv out.csv jobs.csv`

end

def indeed_apply
  apply_now_button = @driver.find_elements(:class,"indeed-apply-button-label")
  return unless apply_now_button.any?

  apply_now_button[0].click

end



def user_applied_response(el)
  puts "applied? y/n or f to copy filepath to clipboard"
  input = gets.chomp

  until input == "y" || input == "n" || input == "done" || input == "d"

    binding.pry if input == "pry"

  until input == "y" || input == "n" || input == "done"
    binding.pry if input == "pry"

    if input == "f"
      file_path_to_clipboard(el)
      puts "copied filepath to clipboard"
    end

    if input == "r"
      recruiter_to_clipboard
      puts "recruiter letter copied"
    end

    input = user_applied_response(el)
  end
  input
end

def navigate_with_rescue_if_closed(el)
  begin
    @driver.navigate.to("http://www.indeed.com" + el[2])
  rescue
    @driver = Selenium::WebDriver.for:chrome
    @driver.navigate.to("http://www.indeed.com" + el[2])
  end
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

def easy_apply_navigate(el)
  sub_url = ""

  if el[2].match(/\/cmp/) || el[2].include?("pagead")
    sub_url = el[2]
  else
    sub_portion = el[2].match(/jk=(.*)/)[1]

    if sub_portion.include?("=")
      sub_portion = sub_portion.match(/.*\&/)[0].chop
    end

    sub_url = "/viewjob?jk=" + sub_portion
  end

  begin
    @driver.navigate.to("http://www.indeed.com" + sub_url)
  rescue
    @driver = Selenium::WebDriver.for:chrome
    @driver.navigate.to("http://www.indeed.com" + sub_url)
  end
end

def get_job_id
end

def lever_fill
  first_name_fill
  last_name_fill
  full_name_fill
  email_fill
  phone_fill
  linkedin_fill
  github_fill
  personal_site_fill
end

def apply_click
  begin
    @driver.find_element(id: "apply").click
  rescue
    return false
  end
  true
end

def continue_click
  begin
    @driver.find_elements(css: "a.button_content.form-page-next")[0].click
  rescue
    return false
  end
  true
end

def save_and_reopen_csv_file(arr)
  CSV.open("out.csv", 'w') do |csv|
    arr.each{|line| csv << line }
  end
  `mv jobs.csv last_run.csv`
  `mv out.csv jobs.csv`
  CSV.table("jobs.csv").to_a
end

def click_through_apply_frame

    indeed_apply
    sleep 2

    @driver.switch_to.frame(@driver.find_elements(tag_name: 'iframe')[-1])
    @driver.switch_to.frame(0)

    if @driver.find_elements(class: "resume_type_toggle_action").length > 0
      @driver.find_elements(class: "resume_type_toggle_action")[0].click
    end

    if @driver.find_elements(id: "resume").length > 0
      @driver.find_element(id: "resume").send_keys("/Users/thomasyancey/Desktop/indeed-apply/tom-yancey-resume.pdf")
    end

    if @driver.find_elements(id: "applicant.applicationMessage").length > 0
      cover_letter_element = @driver.find_element(id: "applicant.applicationMessage")
      cover_letter_element.send_keys(print_cover_letter(el))
    end

    if @driver.find_elements(class: 'form-page-next').length > 0
      @driver.find_elements(class: 'form-page-next')[0].click
      @input = "n"
    elsif @driver.find_elements(id: 'apply').length > 0
      @driver.find_elements(id: 'apply')[0].click
      @input = "y"
      sleep 0.5
    end

end

def easy_apply_run(arr)

  login_to_indeed

    arr[1..-1].each_with_index do |el,i|
    index = i + 1
    puts i
    next if el[5] == "false" || el[4] == "FALSE"
    next if el[9] == "true" || el[9] == "TRUE" #for applied
    next if el[11] == "true" || el[11] == "TRUE" #for skipped
    next if el[12] == "true" || el[12] == "TRUE"

def easy_apply_run(arr)
    arr[1..-1].each_with_index do |el,i|
    index = i + 1
    puts i
    next if el[5] == "false" || el[5] == "FALSE"
    next if el[10] == "true" || el[10] == "TRUE" #for applied

    cover_letter_to_clipboard(el)
    puts "here"
    easy_apply_navigate(el)
    sleep 1

    @input = ""

    if @driver.find_elements(class: "indeed-apply-button-inner").length > 0
      click_through_apply_frame
    elsif @driver.find_elements(class: "view-apply-button").length > 0
      @input = "n"
    end


    unless @input == "y" || @input == "n"
      @input = user_applied_response(el)
    end

    break if @input == "done"
    arr[index][8] = "true"
    arr[index][9] = @input == "y" ? "true" : "false"
    arr[index][10] = Time.now.strftime("%d/%m/%Y %H:%M") if @input == "y"
    arr[index][11] = "true" if @input == "d"
    #needs manual input
    arr[index][12] = @input == "n" ? "true" : "false"

  end

end

run_program
