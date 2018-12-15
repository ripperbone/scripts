#!/usr/bin/env ruby

require 'ffprober'
require 'json'

# Find all M4A files in or beneath the working directory and print the date the song was purchased


file_info = []


Dir.glob("**/*.m4a") do |file|
   ff = Ffprober::Parser.from_file(file)
   purchase_date = ff.json[:format][:tags][:purchase_date]

   file_info << [file, purchase_date] unless purchase_date.nil?

end

file_info.sort_by { |info| info[1] }.each do |info|
   puts "#{info[0]} : #{info[1]}"
end

# list available tags
#puts ff.json[:format][:tags].keys
