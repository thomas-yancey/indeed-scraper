require_relative './personal'

class Job

  include Personal

  attr_accessor :id, :title, :sub_url, :company, :location, :easy_apply, :age, :viewed, :applied, :applied_date, :skip, :needs_manual, :applied_status

  def initialize(params={})
    @driver = params[:driver]
    @id = params[:job_data][0]
    @title = params[:job_data][1]
    @sub_url = params[:job_data][2]
    @company = params[:job_data][3]
    @location = params[:job_data][4]
    @easy_apply = params[:job_data][5]
    @age = params[:job_data][6]
    @query = params[:job_data][8]
    @location = params[:job_data][9]
    @applied = params[:job_data][10]
    @applied_date = params[:job_data][11]
    @needs_manual = params[:job_data][12]
    @applied_status = false
  end

  def back_to_array
    [@id, @title, @sub_url, @company, @location, @easy_apply, @age, @query, @location, @applied, @applied_date, @needs_manual]
  end

  def easy_apply?
    puts @easy_apply
    @easy_apply == 'true'
  end

  def not_yet_applied?
    @applied != 'true'
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
    sleep 4
  end

  def click_through_apply_frame

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
        cover_letter_element.send_keys(self.print_cover_letter)
      end

      if @driver.find_elements(class: 'form-page-next').length > 0
        @driver.find_elements(class: 'form-page-next')[0].click
        # build out for if you have answered questions before
      elsif @driver.find_elements(id: 'apply').length > 0
        @driver.find_elements(id: 'apply')[0].click
        @applied_status = true
        sleep 0.5
      end

  end

  def apply_now_button_click
    apply_now_button = @driver.find_elements(:class,"indeed-apply-button-label")
    return false unless apply_now_button.any?

    apply_now_button[0].click
    true
  end

  def set_apply_status
    if @applied_status
      @applied = 'true'
      @applied_date = Time.now.strftime("%d/%m/%Y %H:%M")
    else
      @needs_manual = 'true'
    end
  end

  def easily_apply
    easy_apply_navigate

    if apply_now_button_click
      click_through_apply_frame
    end

    set_apply_status
    back_to_array
  end


end
