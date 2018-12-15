#!/usr/bin/env ruby

require 'fileutils'

class String
   def to_wav
      return (File.dirname(self).eql?('.') ?
            File.basename(self, '.*') + '.wav' :
            File.join(File.dirname(self), File.basename(self, '.*') + '.wav'))
   end

   def to_mp3
      return (File.dirname(self).eql?('.') ?
          File.basename(self, '.*') + '.mp3' :
          File.join(File.dirname(self), File.basename(self, '.*') + '.mp3'))
   end
end




def convert_to_mp3(file)
   `flac -d \"#{file}\"` unless File.exist? file.to_mp3
   `lame -h -b 192 \"#{file.to_wav}\"` if File.exist? file.to_wav
   FileUtils.rm(file.to_wav, verbose: true) if File.exist? file.to_wav
end

def remove_flac_file(file)
   raise "Extension is not FLAC!" if not File.extname(file).eql? '.flac'
   FileUtils.rm(file, verbose: true) if File.exist? file
end


if ARGV[0].nil?
   puts "usage: #{__FILE__} [ file.flac | --sdcard /path/to/sdcard ]"
   exit(1)
elsif ARGV[0].eql? '--sdcard'

   if not ARGV.size.eql? 2 or not File.directory? ARGV[1]
      puts "Must provide a valid path to the SD card!"
      exit(1)
   else
      Dir.chdir(ARGV[1]) do
         Dir.glob('**/*.flac') do |file|
            Dir.chdir(File.dirname(file)) do
               convert_to_mp3(File.basename(file))
               remove_flac_file(File.basename(file))
            end
         end
      end
   end
else
   flac_file = ARGV[0]

   if not File.exist? flac_file
      puts "File #{flac_file} does not exist!"
      exit(1)
   end

   convert_to_mp3(flac_file)
end


puts "done."
