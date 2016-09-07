require_relative './lib/applier'

applier = Applier.new

def get_user_input
  puts "auto or semi_auto? a/s"
  input = gets.chomp
  until input == "a" || input == "s"
    input = gets_user_input
  end
  input
end

input = get_user_input

if input == "a"
  applier.easy_apply_run
end

if input == "s"
  applier.mostly_easy_apply_run
end
