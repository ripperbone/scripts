#!/usr/bin/env ruby

require 'fileutils'

EXCLUDE_ARTISTS_FILE = File.expand_path('~/.exclude_from_music.txt')


def copy_songs_to_sdcard(path_to_music, destination, artists_to_exclude, dry_run=true)
   Dir.chdir(path_to_music) do
      Dir.glob('**/*.{mp3,m4a,flac}').sort.each do |file|
         next if artists_to_exclude.any? { |artist| artist.strip.eql? file.split('/').first }

         # Skip if MP3 of this song is already on SD Card
         next if File.exists? File.join(destination, File.dirname(file), "#{File.basename(file, '.*')}.mp3") 
         
         if (dry_run)
            puts "[DRY RUN] #{file}"
         else
            FileUtils.mkdir_p File.join(destination, File.dirname(file)), :verbose => true
            FileUtils.cp file, File.join(destination, file), :verbose => true
         end
      end
   end
end



if ARGV.size < 2 or not File.directory? ARGV[0] or ARGV[1].nil?
   #TODO: add better argument parsing
   puts "usage: #{File.basename(__FILE__)} /path/to/music /path/to/sdcard [--dry-run]"
   exit(1)
end

path_to_music = ARGV[0]
path_to_sd_card = ARGV[1]
artists_to_exclude = File.exists?(EXCLUDE_ARTISTS_FILE) ? File.readlines(EXCLUDE_ARTISTS_FILE) : []


copy_songs_to_sdcard(path_to_music, path_to_sd_card, artists_to_exclude, ARGV.include?('--dry-run'))
