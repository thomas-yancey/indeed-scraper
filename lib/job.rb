require_relative './personal'

class Job

  include Personal

  attr_accessor :id, :title, :sub_url, :company, :location, :easy_apply, :age, :viewed, :applied, :applied_date, :query_location, :needs_manual, :applied_status, :already_applied, :choose_not_to_apply

  def initialize(params={})
    @driver = params[:driver]
    @id = params[:job_data][0]
    @title = params[:job_data][1]
    @sub_url = params[:job_data][2]
    @company = params[:job_data][3]
    @location = params[:job_data][4]
    @easy_apply = params[:job_data][5]
    @age = params[:job_data][6]
    @query = params[:job_data][7]
    @query_location = params[:job_data][8]
    @applied = params[:job_data][9]
    @applied_date = params[:job_data][10]
    @needs_manual = params[:job_data][11]
    @applied_status = false
    @already_applied = false
    @choose_not_to_apply = params[:job_data][12] || nil
  end

  def to_array
    [@id, @title, @sub_url, @company, @location, @easy_apply, @age, @query, @query_location, @applied, @applied_date, @needs_manual,@choose_not_to_apply]
  end

  def easy_apply?
    puts @easy_apply
    @easy_apply == 'true'
  end

  def not_yet_applied?
    @applied != 'true'
  end

  def needs_manual?
    puts "needs manual -- #{@needs_manual}"
    puts "comparison #{@needs_manual == 'true'}"
    @needs_manual == 'true'
  end

  def easy_apply_navigate
    puts @id.class
    new_sub_url = ""
    if @sub_url.match(/\/cmp/) || @sub_url.include?("pagead")
      new_sub_url = @sub_url
    else
      new_sub_url = @sub_url.match(/jk=(.*)/)[1]
      if new_sub_url.include?("=")
        new_sub_url = new_sub_url.match(/.*\&/)[0].chop
      end
      new_sub_url = "/viewjob?jk=" + new_sub_url
    end

    begin
      @driver.navigate.to("http://www.indeed.com" + new_sub_url)
    rescue
      @driver = Selenium::WebDriver.for:chrome
      @driver.navigate.to("http://www.indeed.com" + new_sub_url)
    end
    sleep 1
  end

  def click_through_apply_frame

      sleep 2

      @driver.switch_to.frame(@driver.find_elements(tag_name: 'iframe')[-1])
      @driver.switch_to.frame(0)

      select_own_resume_option
      place_pdf_resume
      post_cover_letter

      if @driver.find_elements(class: 'form-page-next').length > 0
        @driver.find_elements(class: 'form-page-next')[0].click
        # build out for if you have answered questions before
      elsif @driver.find_elements(id: 'apply').length > 0
        puts 'applied'
        @driver.find_elements(id: 'apply')[0].click
        @applied_status = true
        sleep 0.5
      elsif @driver.find_elements(id: 'ia_success')
        @already_applied = true
      end

  end

  def select_own_resume_option
    if @driver.find_elements(class: "resume_type_toggle_action").length > 0
      @driver.find_elements(class: "resume_type_toggle_action")[0].click
    end
  end

  def place_pdf_resume
    if @driver.find_elements(id: "resume").length > 0
      @driver.find_element(id: "resume").send_keys("/Users/thomasyancey/Desktop/indeed-apply/tom-yancey-resume.pdf")
    end
  end

  def post_cover_letter
    if @driver.find_elements(id: "applicant.applicationMessage").length > 0
      cover_letter_element = @driver.find_element(id: "applicant.applicationMessage")
      cover_letter_element.send_keys(self.print_cover_letter)
    end
  end

  def apply_now_button_click
    apply_now_button = @driver.find_elements(:class,"indeed-apply-button-label")
    return false unless apply_now_button.any?

    apply_now_button[0].click
    true
  end

  def set_apply_status
    if @applied_status || @already_applied
      @applied = 'true'
      @applied_date = Time.now.strftime("%d/%m/%Y %H:%M")
    else
      @needs_manual = 'true'
    end
  end

  def start_form
    easy_apply_navigate

    if apply_now_button_click
      click_through_apply_frame
    end

    input = user_input_applied
    set_semi_applied_status(input)
    self.to_array
  end

  def set_semi_applied_status(input)
    if input == "y"
      @applied = 'true'
      @applied_date = Time.now.strftime("%d/%m/%Y %H:%M")
    else
      @choose_not_to_apply = 'true'
    end

  end

  def user_input_applied

    puts "applied? y/n"
    input = gets.chomp

    until input == "y" || input == "n"
      user_input_applied
    end
    input
  end


  def easily_apply
    easy_apply_navigate

    if apply_now_button_click
      click_through_apply_frame
    end

    set_apply_status
    self.to_array
  end

  def change_age_to_numeric

    return @age if @age.is_a?(Fixnum)

    @age = 0 if @age.match(/hours/)
    @age = 31 if @age == "30+ days ago"

    return @age if @age.is_a?(Fixnum)

    num_match = @age.match(/[0-9]+/)[0] if !!@age.match(/[0-9]+/)

    if num_match
      @age = num_match.to_i
    end

    @age

  end



end
