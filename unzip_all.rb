#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'


Dir.glob("*.zip") do |zip|
   puts zip
   #output_dir = File.basename(zip, '.*').gsub(/\s+/, '_')
   output_dir = File.basename(zip, '.*')
   if File.directory?(output_dir)
      puts "ERROR: #{output_dir} already exists"
      exit(1)
   end

   FileUtils.mkdir(output_dir, verbose: true)
   #system("unzip -d #{output_dir} -j #{zip}")
   system("unzip -d \"#{output_dir}\" \"#{zip}\"")
   if !$?.exitstatus.eql?(0)
      puts "unzip unsuccessful: #{$?.exitstatus}"
      FileUtils.rmdir(output_dir, verbose: true) if Dir.empty?(output_dir)
      exit(1)
   end
   #Dir.glob("#{output_dir}/*") do |file|
   #   FileUtils.chmod(0644, file, verbose: true)
   #end

   FileUtils.rm(zip, verbose: true)
end
