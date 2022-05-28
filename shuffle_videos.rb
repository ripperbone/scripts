#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'tempfile'


options = { count: 1 }
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
   opts.on("-m", "--mute", TrueClass, "mute video sound") do |v|
      options[:mute] = v
   end
end.parse!

selections = Dir.glob("**/*.{mp4,mov,m4v,mkv,avi}")
   .uniq
   .reject { |file| !options[:include].nil? and !options[:include].match(file) }
   .reject { |file| !options[:exclude].nil? and options[:exclude].match(file) }
   .sample(options[:count])
exit(0) if selections.nil? or selections.size.eql?(0)
puts selections

file = Tempfile.new(File.basename(__FILE__))
selections.each { |selection| file.puts(selection) }
file.close
#pid = Process.spawn("mpv --mute=#{options[:mute] ? 'yes' : 'no'} --loop-playlist=inf --playlist=-", in: file.path, out: "/dev/null", err: "/dev/null")
pid = Process.spawn("mpv --mute=#{options[:mute] ? 'yes' : 'no'} --loop-playlist=inf --playlist=-", in: file.path)
puts pid
