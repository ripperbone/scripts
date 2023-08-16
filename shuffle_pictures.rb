#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'time'

jpegview_sort = { file_name: 'n', modified_date: 'm', random: 'z' }

options = { program: :eog, slideshow_seconds: 3, search_recursive: false, monitor: 0, sort: :file_name }
OptionParser.new do |opts|
   opts.on("-e PATTERN", "--exclude PATTERN", Regexp, "specify a pattern to exclude") do |v|
      options[:exclude] = v
   end
   opts.on("-i PATTERN", "--include PATTERN", Regexp, "specify a pattern to include") do |v|
      options[:include] = v
   end
   # use -a no or -a false to set to false
   opts.on("-a", "--all [FLAG]", TrueClass, "start a slide show for each selection") do |v|
      options[:all] = v.nil? ? true : v
   end
   opts.on("--after DATE", String, "include directories with modified date after specified date") do |v|
      options[:after] = Time.strptime(v, "%Y-%m-%d")
   end
   opts.on("--before DATE", String, "include directories with modified date before specified date") do |v|
      options[:before] = Time.strptime(v, "%Y-%m-%d")
   end
   opts.on("--today", TrueClass, "include directories with modified date of today") do |_v|
      options[:after] = Time.new(Date.today.year, Date.today.month, Date.today.day)
   end
   opts.on("-p PROGRAM", "--program PROGRAM", %i[jpegview eog], "the program to use for slide show") do |v|
      options[:program] = v
   end
   opts.on("-s SECONDS", Integer, "slide show seconds between each picture") do |v|
      options[:slideshow_seconds] = v
   end
   opts.on("-r", TrueClass, "recurse into child directories") do |v|
      options[:search_recursive] = v
   end
   opts.on("-m NUMBER", "--monitor NUMBER", Integer, "specify a monitor index 0,1,...") do |v|
      options[:monitor] = v
   end
end.parse!

puts options

selections = (options[:search_recursive] ? Dir.glob("**/*") : Dir.entries('.').reject { |file| ['..', '.'].include?(file) })
   .select { |file| File.directory?(file) }
   .uniq
   .reject { |file| !options[:include].nil? and !options[:include].match(file) }
   .reject { |file| !options[:exclude].nil? and options[:exclude].match(file) }
   .reject { |file| !options[:after].nil? and File.mtime(file) < options[:after] }
   .reject { |file| !options[:before].nil? and File.mtime(file) > options[:before] }
   .select { |dir| Dir.entries(dir).any? { |file| ['.jpg', '.jpeg'].include?(File.extname(file).downcase) }}.shuffle

selections = [selections.first] if selections.size > 1 and !options[:all]

puts selections
puts
until selections.empty?
   selection = selections.pop
   puts selection

   case options[:program]
   when :jpegview
      # for windows
      # choco install jpegview or get from: https://github.com/sylikc/jpegview
      cmd = ["jpegview"]
      cmd << "\"#{selection}\""
      cmd << "/slideshow"
      cmd << options[:slideshow_seconds]
      cmd << "/fullscreen"
      cmd << "/monitor"
      cmd << options[:monitor]
      cmd << "/order"
      cmd << jpegview_sort[options[:sort]]
      proc_pid = Process.spawn(cmd.join(" "))
      break if selections.size.eql?(0)

      begin
         gets
      rescue Interrupt
         print "\nExiting...\n"
         exit(0)
      end

      tasks = `tasklist`.split(/\r?\n/).map { |line| line.lstrip.split(/\s+/)[0..1] }.reject { |task| task[0].nil? }

      matching_pids = tasks.select { |task| task[0].downcase.eql?("jpegview.exe") }.map { |task| task[1].to_i }

      if matching_pids.first.eql?(proc_pid)
         puts "closing process #{proc_pid}"
         Process.kill('KILL', proc_pid)
         sleep(1)
      end

   when :eog
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
end
