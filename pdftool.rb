#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'fileutils'

options = { rotate_pages: [] }
parser = OptionParser.new do |opts|
   opts.on("--file FILE", String, "pdf file") do |v|
      options[:file] = v
   end
   opts.on("--rotate PAGE", Integer, "page to rotate") do |v|
      options[:rotate_pages] << v
   end
end
parser.parse!

if options[:file].nil?
   puts "please provide a file name!"
   exit(1)
end
puts options[:file]


# split pdf into jpgs for each page

system("pdftoppm -jpeg -r 500 \"#{options[:file]}\" \"pages\"")

Dir.glob("pages-*\.jpg") do |page|
   current_page = File.basename(page, '.*').split("-")[-1]
   puts "current page is #{current_page}"
   if options[:rotate_pages].include?(current_page.to_i)
      puts "rotating page #{page}..."
      system("convert \"#{page}\" -rotate -90 \"ROTATED-#{page}\"")
      FileUtils.mv("ROTATED-#{page}", page, verbose: true)
   end

   # clean up the pdf. This may take forever and options may require tweaking
   system("convert -density 500 \"#{page}\" -threshold 70% -type bilevel -compress fax \"OUTPUT-#{page}\"")
   FileUtils.mv("OUTPUT-#{page}", page, verbose: true)
   system("convert \"#{page}\" \"#{File.basename(page, '.*')}.pdf\"")
end

new_pdf_name = "OUTPUT_#{options[:file]}"
puts "combining pages to #{new_pdf_name}"

system("pdfunite #{Dir["pages-*\.pdf"].map { |page| "\"#{page}\"" }.join(' ')} \"#{new_pdf_name}\"")
