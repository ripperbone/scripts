#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'time'
require 'tempfile'

def shuffle(selections, count)
   count.nil? ? selections.shuffle : selections.sample(count)
end

options = { count: 1, player: :totem }
OptionParser.new do |opts|
   opts.on("-e PATTERN", "--exclude PATTERN", Regexp, "specify a pattern to exclude") do |v|
      options[:exclude] = v
   end
   opts.on("-i PATTERN", "--include PATTERN", Regexp, "specify a pattern to include") do |v|
      options[:include] = v
   end
   opts.on("-c NUM", "--count NUM", Integer, "the number of selections to add to playlist") do |v|
      options[:count] = v
   end
   # use -a no or -a false to set to false
   opts.on("-a", "--all [FLAG]", TrueClass, "add all selections to the playlist") do |v|
      options[:count] = v.eql?(false) ? 1 : nil
   end
   opts.on("--after DATE", String, "include files with modified date after specified date") do |v|
      options[:after] = Time.strptime(v, "%Y-%m-%d")
   end
   opts.on("--before DATE", String, "include files with modified date before specified date") do |v|
      options[:before] = Time.strptime(v, "%Y-%m-%d")
   end
   opts.on("--today", TrueClass, "include files with modified date of today") do |_v|
      options[:after] = Time.new(Date.today.year, Date.today.month, Date.today.day)
   end
   opts.on("-m", "--mute", TrueClass, "mute video sound") do |v|
      options[:mute] = v
   end
   opts.on("-p PLAYER", "--player PLAYER", %i[totem mpv vlc], "specify video player to use") do |v|
      options[:player] = v
   end
end.parse!

selections = shuffle(
   Dir.glob("**/*.{mp4,mov,m4v,mkv,avi}")
   .uniq
   .reject { |file| !options[:include].nil? and !options[:include].match(file) }
   .reject { |file| !options[:exclude].nil? and options[:exclude].match(file) }
   .reject { |file| !options[:after].nil? and File.mtime(file) < options[:after] }
   .reject { |file| !options[:before].nil? and File.mtime(file) > options[:before] },
   options[:count]
)
exit(0) if selections.nil? or selections.size.eql?(0)
puts selections

case options[:player]
when :totem
   cmd = ["totem"]
   cmd << "--mute" if options[:mute]
   cmd << "--fullscreen"
   cmd << "--enqueue"
   cmd << selections.map { |selection| "\"#{selection}\"" }
   pid = Process.spawn(cmd.join(' '), out: "/dev/null", err: "/dev/null")
   puts pid
when :vlc
   cmd = ["vlc"]
   cmd << "--loop"
   cmd << "--fullscreen"
   cmd << selections.map { |selection| "\"#{selection}\"" }
   pid = Process.spawn(cmd.join(' '))
   puts pid
when :mpv
   # mpv
   file = Tempfile.new(File.basename(__FILE__))
   selections.each { |selection| file.puts(selection) }
   file.close
   #pid = Process.spawn("mpv --mute=#{options[:mute] ? 'yes' : 'no'} --loop-playlist=inf --playlist=-", in: file.path, out: "/dev/null", err: "/dev/null")
   pid = Process.spawn("mpv --mute=#{options[:mute] ? 'yes' : 'no'} --loop-playlist=inf --playlist=-", in: file.path)
   puts pid
else
   puts "video player not expected"
   exit(1)
end
