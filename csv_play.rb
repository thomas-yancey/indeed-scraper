require 'selenium-webdriver'
require 'pry'
require 'csv'
require 'nokogiri'


def print_cover_letter(el)
  return "Dear Hiring Manager,

With my skill set and experience, I believe I would make a great addition to the #{el[3]} team. I have experience with multiple web technologies, including Ruby on Rails, Javascript, HTML5, CSS3, React.js, PostgreSQL, responsive frameworks like Bootstrap and Skeleton, and behavior driven development frameworks like Jasmine and RSpec. I have built a number of passion projects using these technologies, including CitiBike Map, a live station feed map of New York City CitiBike locations. The app was built using Ruby on Rails, a vanilla Javascript MVC frontend, and the Google Maps API.

Whether it’s a team project or my personal website (www.tomyancey.me) , I always insist on a high level of quality and stability.

For all of the reasons above, I believe I would make a great addition to your team. I have attached my resume for your consideration and look forward to hearing from you.

Best Regards,
Thomas Yancey"
end

def cover_letter_to_clipboard(el)
  `echo "#{print_cover_letter(el)}" | pbcopy`
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

  until input == "y" || input == "n" || input == "done"
    binding.pry if input == "pry"
    if input == "f"
      file_path_to_clipboard(el)
      puts "copied filepath to clipboard"
    end

    input = user_applied_response(el)
  end
  input
end

def first_name_fill
  @driver.find_elements(:name, "first_name")[0].send_keys("Thomas") if @driver.find_elements(:name, "first_name").any?
  @driver.find_elements(:id, "first_name")[0].send_keys("Thomas") if @driver.find_elements(:id, "first_name").any?
end

def last_name_fill
  @driver.find_elements(:name, "last_name")[0].send_keys("Yancey") if @driver.find_elements(:name, "last_name").any?
end

def full_name_fill
  @driver.find_elements(:name, "name")[0].send_keys("Thomas Yancey") if @driver.find_elements(:name, "name").any?
  @driver.find_elements(:name, "full_name")[0].send_keys("Thomas Yancey") if @driver.find_elements(:name, "full_name").any?
end

def email_fill
  @driver.find_elements(:name, "email")[0].send_keys("tomyancey1@gmail.com") if @driver.find_elements(:name, "email").any?
end

def phone_fill
  @driver.find_elements(:name, "phone")[0].send_keys("(703) 785-4210") if @driver.find_elements(:name, "phone").any?
end

def linkedin_fill
  @driver.find_elements(:name, "urls[LinkedIn]")[0].send_keys("www.linkedin.com/in/tomyancey") if @driver.find_elements(:name, "urls[LinkedIn]").any?
  @driver.find_elements(:name, "linkedin")[0].send_keys("www.linkedin.com/in/tomyancey") if @driver.find_elements(:name, "linkedin").any?
end

def github_fill
  @driver.find_elements(:name, "urls[Github]")[0].send_keys("www.github.com/thomas-yancey") if @driver.find_elements(:name, "urls[Github]").any?
  @driver.find_elements(:name, "github")[0].send_keys("www.github.com/thomas-yancey") if @driver.find_elements(:name, "github").any?
end

def personal_site_fill
  @driver.find_elements(:name, "urls[Portfolio]")[0].send_keys("www.tomyancey.me") if @driver.find_elements(:name, "urls[Portfolio]").any?
  @driver.find_elements(:name, "portfolio")[0].send_keys("www.tomyancey.me") if @driver.find_elements(:name, "portfolio").any?
end

def navigate_with_rescue_if_closed(el)
  begin
    @driver.navigate.to("http://www.indeed.com" + el[2])
  rescue
    @driver = Selenium::WebDriver.for:chrome
    @driver.navigate.to("http://www.indeed.com" + el[2])
  end
end

def easy_apply_navigate(el)
  sub_url = ""

  if el[2].match(/\/cmp/) || el[2].include?("pagead")
    sub_url = el[2]
  else
    sub_portion = el[2].match(/jk=(.*)/)[1]

    if sub_portion.include?("=")
      sub_portion = sub_portion.split("=")[0]
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

def has_class_element(el)
end

def has_id_element(el)
end

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
    input = ""
    if @driver.find_elements(class: "indeed-apply-button-inner").length > 0
      indeed_apply
      sleep 2
      @driver.switch_to.frame(@driver.find_elements(tag_name: 'iframe')[-1])
      @driver.switch_to.frame(0)

      if @driver.find_elements(id: "applicant.name").length > 0
        @driver.find_element(id: "applicant.name").send_keys("Thomas Yancey")
      end

      if @driver.find_elements(id: "applicant.firstName").length > 0
        @driver.find_element(id: "applicant.firstName").send_keys("Thomas")
      end

      if @driver.find_elements(id: "applicant.lastName").length > 0
        @driver.find_element(id: "applicant.lastName").send_keys("Yancey")
      end

      if @driver.find_elements(id: "applicant.email").length > 0
        @driver.find_element(id: "applicant.email").send_keys("tomyancey1@gmail.com")
      end

      if @driver.find_elements(id: "applicant.phoneNumber").length > 0
        @driver.find_element(id: "applicant.phoneNumber").send_keys("(703) 785-4210")
      end

      @driver.find_element(id: "resume").send_keys("/Users/thomasyancey/Desktop/indeed-apply/Thomas_Yancey_ Resume.pdf")
      cover_letter_element = @driver.find_element(id: "applicant.applicationMessage")
      cover_letter_element.send_keys(print_cover_letter(el))
      sleep 1
      binding.pry
      if apply_click
        puts "apply click"
        input = "y"
      else
        puts "continue click"
        # continue_click
      end
    end

    unless input == "y"
      input = user_applied_response(el)
    end

    break if input == "done"
    arr[index][9] = "true"
    arr[index][10] = input == "y" ? "true" : "false"
    arr[index][11] = Time.now.strftime("%d/%m/%Y %H:%M") if input == "y"

  end

end

run_program
