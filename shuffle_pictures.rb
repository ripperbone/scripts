#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

options = { program: :eog, slideshow_seconds: 3 }
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
   opts.on("-p PROGRAM", "--program PROGRAM", %i[jpegview eog], "the program to use for slide show") do |v|
      options[:program] = v
   end
   opts.on("-s SECONDS", Integer, "slide show seconds between each picture") do |v|
      options[:slideshow_seconds] = v
   end
end.parse!

selections = Dir.glob("**/*")
   .select { |file| File.directory?(file) }
   .uniq
   .reject { |file| !options[:include].nil? and !options[:include].match(file) }
   .reject { |file| !options[:exclude].nil? and options[:exclude].match(file) }
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
      #cmd << "/fullscreen"
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
