require 'csv'

require_relative 'job'

class Jobs

  attr_accessor :driver, :jobs_array, :new_jobs_array

  def initialize(params={})
    @driver = params[:driver]
    @filename = params[:filename]
    @jobs_array = []

    CSV.foreach(params[:filename]) do |job|
      @jobs_array << Job.new({job_data: job, driver: @driver})
    end
    @new_jobs_array = []
    @backup_CSV = "backup.csv"
  end

  def save_all_jobs
    self.jobs_array.each do |thing|
      # CSV.open()
    end
  end

  def apply_easy_jobs


    self.jobs_array.each_with_index do |job, idx|

      result = job.to_array

      if job.easy_apply? && job.not_yet_applied? && !job.needs_manual?
        result = job.easily_apply
        p "#{jobs_array.length} #{idx}"
      end

      p result
      @new_jobs_array <<  result
      self.add_result_to_backup_csv(result)

    end

    self.replace_contents_of_jobs_csv

  end

  def mostly_easy_apply_jobs

    continue = true

    self.jobs_array.each_with_index do |job, idx|
      break if continue == false
      puts "#{job.id} #{job.easy_apply?} #{job.not_yet_applied?} #{job.needs_manual?}"

      result = job.to_array

      if job.easy_apply? && job.not_yet_applied? && job.needs_manual?
        result = job.start_form
        continue = continue_input
      end

      p result
      p "#{idx} #{self.jobs_array.length}"

      self.jobs_array[idx] =  result
      self.add_result_to_backup_csv(result)
    end

    self.replace_contents_of_jobs_csv
  end

  def continue_input
    puts "continue? y/n"
    input = gets.chomp
    until input == "y" || input == "n"
      puts "continue? y/n"
      input = gets.chomp
    end

    input == "y" ? true : false
  end

  def add_result_to_backup_csv(result)
    CSV.open("backup.csv", "a+") do |csv|
      csv << result
    end
  end

  def replace_contents_of_jobs_csv
    CSV.open("out.csv", 'w') do |csv|
      @jobs_array.each do |job_data|
        if job_data.kind_of?(Array)
          csv << job_data
        else
          csv << job_data.to_array
        end
      end
    end
    `mv jobs.csv last_run.csv`
    `mv out.csv jobs.csv`
  end

end
