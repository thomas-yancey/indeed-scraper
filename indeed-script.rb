require 'selenium-webdriver'
require 'nokogiri'
# require 'pry'
require 'csv'

def initial_search(query,location)

  what_element = @driver.find_element(:name, 'q')
  what_element.send_keys(query)

  where_element = @driver.find_element(:name, 'l')
  where_element.clear
  where_element.send_keys(location)

  what_element.submit
end

def close_modal
  return if @driver.find_elements(:id, 'prime-popover-x').empty?
  pop = @driver.find_element(:id, 'prime-popover-x')
  pop.click if pop #for modal, need to find if modal is displaying instead if this breaks load
end


def collect_divs_with_row_in_class_name(doc)
  doc.css("div").select { |div| div.attributes["class"].value.include?("row") if div.attributes["class"] && div["class"]}
end

def join_and_strip_child_text(el)
  el.children.collect {|child| child.text }.join(" ").strip
end

def grab_job_id(div)
  div.attributes["id"].value
end


def grab_job_title_loop(div)
  return div if div.class == String

  div.children.each do |el|
    if el.attributes && el.attributes["title"]
      return el.attributes["title"].value
    end

    unless el.children.length == 0
      res = grab_job_title_loop(el)
      return res if res.class == String
    end
  end
end

def grab_external_url_loop(div)
  return div if div.class == String

  div.children.each do |el|
    if el.attributes && el.attributes["href"]
      return el.attributes["href"].value
    end

    unless el.children.length == 0
      res = grab_external_url_loop(el)
      return res if res.class == String
    end
  end

end

def grab_age_loop(div)

  return div if div.class == String || div == false
  div.children.each do |el|

    if el.name && el.attributes["class"]
      if el.attributes["class"].value == "date"
        return join_and_strip_child_text(el)
      end
    end

    unless el.children.length == 0
      res = grab_age_loop(el)
      return grab_age_loop(res) if res.class == String
    end

  end
end

def grab_company_loop(div)

  return div if div.class == String || div == false
  div.children.each do |el|

    if el.name && el.attributes["class"]
      if el.attributes["class"].value == "company"
        return join_and_strip_child_text(el)
      end
    end

    unless el.children.length == 0
      res = grab_company_loop(el)
      return grab_company_loop(res) if res.class == String
    end

  end
end

def grab_location_loop(div)

  return div if div.class == String || div == false
  div.children.each do |el|

    if el.name && el.attributes["class"]
      if el.attributes["class"].value == "location"
        return join_and_strip_child_text(el)
      end
    end

    unless el.children.length == 0
      res = grab_location_loop(el)
      return grab_location_loop(res) if res.class == String
    end

  end
end

def grab_easy_apply_loop(div)
  return div if div == true
  div.children.each do |el|

    if el.name && el.attributes["class"]

      if el.attributes["class"].value == "iaP"
        return true
      end
    end

    unless el.children.length == 0
      res = grab_easy_apply_loop(el)
      return grab_easy_apply_loop(res) if res == true
    end
  end
  false
end

def next_page_sub_uri(pagination)
  bold_number = false
  pagination.children.each do |child|

    bold_number = true if child.name == "b"

    if bold_number && child.name == "a"
      return child.attributes["href"].value
    end

  end
end

def grab_all_fields_from_div(div)
    arr = []
    arr << grab_job_id(div)
    arr << grab_job_title_loop(div)
    arr << grab_external_url_loop(div)
    arr << grab_company_loop(div)
    arr << grab_location_loop(div)
    arr << grab_easy_apply_loop(div)
    arr << grab_age_loop(div)
    arr.push(@query,@location, "false")
    arr
end

def return_all_job_ids_in_queue(file_name)
  job_ids_array = []
  CSV.foreach(file_name) {|row| job_ids_array << row[0]}
  job_ids_array
end

def add_jobs

  puts "Job search"
  query = gets.chomp
  puts "location search"
  location = gets.chomp

  @driver = Selenium::WebDriver.for:chrome
  @driver.navigate.to "http://www.indeed.com"

  f = CSV.open("./jobs.csv", "a+")
  job_ids_already_in_queue = return_all_job_ids_in_queue("./jobs.csv")
  count = 10

  initial_search(query,location)
  close_modal

  base_uri = @driver.current_url

  until count == 500

    doc = Nokogiri::HTML(@driver.page_source)
    pagination = doc.css("div").find {|div| div.attr('class') == "pagination" }
    divs = collect_divs_with_row_in_class_name(doc)

    divs.each do |div|
      div_data = grab_all_fields_from_div(div)

      unless job_ids_already_in_queue.include?(div_data[0])
        f << div_data
        job_ids_already_in_queue << div_data[0]
      end
    end

    sleep 2
    @driver.navigate.to(base_uri + "&start=#{count}" )
    count += 3
  end
  f.close
end


add_jobs
#Get title right, and get dates old

#seperate and put into csv files based upon easy apply or not
#div id is the job id, so do not place duplicates
#get pagination working to collect all jobs
#figure out submit as quickly as possible
#switch xxxx out for company name in cover letter
#after submit move to submitted csv and remove from jobs csv
#check submitted and queue csvs for jobs before adding



@driver.quit
