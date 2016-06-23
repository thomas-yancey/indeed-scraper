`ls ./new_job_cover_letters> cover_letters.txt`
f = File.open("cover_letters.txt","r")
new_file = File.open("create_folders.txt","w+")

f.each_line do |line|
  dir_file_name = line.gsub(".pdf","").chomp
  new_file << "[ -d cover_letters/#{dir_file_name} ] || mkdir cover_letters/#{dir_file_name}\n"
  new_file << "mv new_job_cover_letters/#{line.chomp} cover_letters/#{dir_file_name}/\n"
  new_file << "mv cover_letters/#{dir_file_name}/#{line.chomp} cover_letters/#{dir_file_name}/Thomas_Yancey_Cover_Letter.pdf\n"
end

`mv create_folders.txt create_folders.sh`
`chmod 744 create_folders.sh`
`./create_folders.sh`