module LeverForm

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

end
