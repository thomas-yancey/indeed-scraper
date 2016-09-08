require_relative './lib/applier'

applier = Applier.new

def get_user_input
  puts "auto,semi_auto or update csv? a/s/u"
  input = gets.chomp
  until input == "a" || input == "s" || input == "u"
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

if input == "u"
  applier.update_ages_and_sort
end
