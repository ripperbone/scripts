#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

# Rename music files purchased from Qobuz

Dir.glob("*.flac") do |filename|

   # SMR - Studio Master Recording
   # LLS - Lossless

   _disk_number, track_number, _artist, track_name, _format, file_ext = filename.match(/^(\d{2})-(\d{2})-(.*)-(.*)-(SMR|LLS)\.(.*)$/).captures

   #puts disk_number
   #puts track_number
   #puts artist
   #puts track_name
   #puts format
   #puts file_ext


   new_filename = "#{track_number} #{track_name.gsub(/_/, ' ')}.#{file_ext}"


   #puts "#{filename} --> #{new_filename}"
   FileUtils.mv(filename, new_filename, verbose: true)
end
