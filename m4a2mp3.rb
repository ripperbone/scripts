#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'fileutils'

class String
   def to_wav
      return (File.dirname(self).eql?('.') ?
            "#{File.basename(self, '.*')}.wav" :
            File.join(File.dirname(self), "#{File.basename(self, '.*')}.wav"))
   end

   def to_mp3
      return (File.dirname(self).eql?('.') ?
          "#{File.basename(self, '.*')}.mp3" :
          File.join(File.dirname(self), "#{File.basename(self, '.*')}.mp3"))
   end
end

def convert_to_mp3(file)
   # puts "faad \"#{file}\"" unless File.exist? file.to_mp3
   `faad \"#{file}\"` unless File.exist? file.to_mp3
   # puts "lame -h -b 320 \"#{file.to_wav}\"" if File.exist? file.to_wav
   `lame -h -b 320 \"#{file.to_wav}\"` if File.exist? file.to_wav
   FileUtils.rm(file.to_wav, verbose: true) if File.exist? file.to_wav
end

def remove_m4a_file(file)
   raise "Extension is not M4A!" if not File.extname(file).eql? '.m4a'
   FileUtils.rm(file, verbose: true) if File.exist? file
end

options = {}
parser = OptionParser.new do |opts|
   opts.on("--file FILE", String, "the m4a file to convert to mp3") do |v|
      options[:file] = v
   end
   opts.on("--sdcard PATH", String, "the path to the SD card") do |v|
      options[:path_to_sdcard] = v
   end
end
parser.parse!

if !options[:path_to_sdcard].nil? and !options[:path_to_sdcard].empty?

   if File.directory?(options[:path_to_sdcard])
      Dir.chdir(options[:path_to_sdcard]) do
         Dir.glob('**/*.m4a') do |file|
            Dir.chdir(File.dirname(file)) do
               convert_to_mp3(File.basename(file))
               remove_m4a_file(File.basename(file))
            end
         end
      end
   else
      puts "Must provide a valid path to the SD card!"
      exit(1)
   end

elsif !options[:file].nil? and !options[:file].empty?

   if not File.exist?(options[:file])
      puts "File #{options[:file]} does not exist!"
      exit(1)
   end

   convert_to_mp3(options[:file])
else
   puts parser.help
   exit(1)
end

puts "done."
