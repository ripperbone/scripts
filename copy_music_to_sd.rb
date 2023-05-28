#!/usr/bin/env ruby
#frozen_string_literal: true

require 'optparse'
require 'fileutils'

EXCLUDE_ARTISTS_FILE = File.expand_path('~/.exclude_from_music.txt')


def copy_songs_to_sdcard(path_to_music, destination, artists_to_exclude, dry_run)
   Dir.chdir(path_to_music) do
      Dir.glob('**/*.{mp3,m4a,flac}').sort.each do |file|
         next if artists_to_exclude.include? file.split('/').first

         # Skip if file is already on SD card
         next if File.exist? File.join(destination, File.dirname(file), File.basename(file))

         # Skip if MP3 of this song is already on SD Card
         next if File.exist? File.join(destination, File.dirname(file), "#{File.basename(file, '.*')}.mp3")

         if dry_run
            puts "[DRY RUN] #{file}"
         else
            FileUtils.mkdir_p File.join(destination, File.dirname(file)), verbose: true
            FileUtils.cp file, File.join(destination, file), verbose: true
         end
      end
   end
end

def list_directories_now_excluded(destination, artists_to_exclude)
   Dir.chdir(destination) do
      Dir.glob('*').select { |file| File.directory?(file) and artists_to_exclude.include?(file) }.each do |dir|
         puts "[INFO] '#{dir}' is on SD card but is in exclude file."
      end
   end
end

def list_artists(path_to_music, destination)
   return Dir.entries(path_to_music).select { |file| File.directory?(File.join(path_to_music, file)) }
         .reject { |dir| ['.', '..'].include?(dir) }
         .sort
         .map { |dir| Dir.entries(destination).include?(dir) ? "# #{dir}" : dir }
end

options = { dry_run: false, excludes_file: EXCLUDE_ARTISTS_FILE, list_artists: false }
parser = OptionParser.new do |opts|
   opts.on("--music PATH", String, "the path to the music files [required]") do |v|
      options[:path_to_music] = v
   end
   opts.on("--sdcard PATH", String, "the path to the SD card [required]") do |v|
      options[:path_to_sdcard] = v
   end
   opts.on("--dry-run", TrueClass, "perform a trial run with no changes made") do |v|
      options[:dry_run] = v
   end
   opts.on("--excludes-file PATH", String, "the path to the excludes file") do |v|
      options[:excludes_file] = v
   end
   opts.on("--list-artists", TrueClass, "list artists for excludes file") do |v|
      options[:list_artists] = v
   end
end
parser.parse!

[["--music", :path_to_music], ["--sdcard", :path_to_sdcard]].each do |switch, opt|
   if options[opt].nil? or options[opt].empty?
      puts "option #{switch} is required!"
      puts parser.help
      exit(1)
   end

   if !File.directory?(options[opt])
      puts "directory #{options[opt]} does not exist!"
      exit(1)
   end
end

if options[:list_artists]
   puts list_artists(options[:path_to_music], options[:path_to_sdcard])
   exit(0)
end

artists_to_exclude = File.exist?(options[:excludes_file]) ? File.readlines(options[:excludes_file]).map(&:strip).reject { |line| line.start_with?('#') } : []


copy_songs_to_sdcard(options[:path_to_music], options[:path_to_sdcard], artists_to_exclude, options[:dry_run])
list_directories_now_excluded(options[:path_to_sdcard], artists_to_exclude)
