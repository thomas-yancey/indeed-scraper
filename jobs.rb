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
  end

  def save_all_jobs
    self.jobs_array.each do |thing|
      # CSV.open()
    end
  end

  def apply_easy_jobs

    self.jobs_array.each_with_index do |job, idx|
      puts "#{job.id} #{job.easy_apply?} #{job.not_yet_applied?}"
      puts idx
      if job.easy_apply? && job.not_yet_applied?
        @new_jobs_array << job.easily_apply
      else
        @new_jobs_array << job.easily_apply
      end
      puts new_jobs_array
    end
  end

end
