#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

options = {}
OptionParser.new do |opts|
   opts.on("-e PATTERN", "--exclude PATTERN", Regexp, "specify a pattern to exclude") do |v|
      options[:exclude] = v
   end
   opts.on("-i PATTERN", "--include PATTERN", Regexp, "specify a pattern to include") do |v|
      options[:include] = v
   end
   opts.on("-a", "--all", TrueClass, "start a slide show for each selection") do |_v|
      options[:all] = true
   end
end.parse!

selections = Dir.glob("**/*")
   .select { |file| File.directory?(file) }
   .uniq
   .reject { |file| !options[:include].nil? and !options[:include].match(file) }
   .reject { |file| !options[:exclude].nil? and options[:exclude].match(file) }
   .select { |dir| Dir.entries(dir).any? { |file| ['.jpg', '.jpeg'].include?(File.extname(file).downcase) }}.shuffle

selections = [selections.first] if selections.size > 1 and !options[:all]

until selections.empty?
   selection = selections.pop
   puts selection
   proc_pid = Process.spawn("eog --slide-show \"#{selection}\"", out: "/dev/null", err: "/dev/null")
   child_pid = `pgrep -P #{proc_pid}`.to_i
   puts "pid: #{child_pid}"
   break if selections.size.eql?(0)

   begin
      gets
   rescue Interrupt
      print "\nExiting...\n"
      exit(0)
   end

   pids_list = `ps -u #{ENV['USER']} -o pid=`.split("\n").map { |pid| pid.strip.to_i }

   if pids_list.include?(child_pid)
      Process.kill('TERM', child_pid)
      sleep(1)
   end

end
