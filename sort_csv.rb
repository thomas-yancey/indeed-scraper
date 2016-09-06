require 'csv'

def string_to_day_count(el)
  return 0 if el.match("hours")
  return 31 if el.match(/\d+[+]/)
  el.scan(/\d+/)[0].to_i
end


def loop_through_and_convert
  arr = []
  CSV.foreach("./jobs.csv").with_index do |row,csv_idx|
    line_arr = []
    row.each_with_index do |el,idx|
      if idx == 6 && csv_idx != 0
        line_arr << string_to_day_count(el)
      else
        line_arr << el
      end
    end
    arr << line_arr
  end
  arr
end

converted = loop_through_and_convert

csv = CSV.open("test_run.csv","w+") do |csv_line|
  csv_line << converted.shift
  converted.sort_by! {|line| line[6]}
  converted.each do |line|
    csv_line << line
  end
end
