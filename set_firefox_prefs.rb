#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

if !`pgrep firefox`.empty?
   puts "There is already a running firefox process. Close it first"
   exit(1)
end

puts "Cleaning up files in /tmp..."
Dir.glob("/tmp/tmpaddon*").select { |match| File.stat(match).writable? }.each { |match| FileUtils.rm(match, verbose: true) } if File.directory?("/tmp")

if File.directory?("#{Dir.home}/.mozilla/firefox")
   puts "Settings directory exists. Deleting it..."
   FileUtils.rm_r("#{Dir.home}/.mozilla/firefox", verbose: true)
end

puts "Starting firefox to create default settings"
pid = Process.spawn("firefox --headless", out: "/dev/null", err: "/dev/null")
puts pid
puts "Waiting for firefox to start up"
sleep(15) # this is probably longer than necessary
puts "Quitting firefox..."
Process.kill('HUP', pid)

settings_dir = Dir.glob("#{Dir.home}/.mozilla/firefox/*.default-release").first

if settings_dir.nil?
   puts "Firefox settings directory does not exist"
   exit(1)
end

prefs_file = File.join(settings_dir, "user.js")

puts prefs_file

File.open(prefs_file, 'a') do |prefs|
   prefs << %{
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.startup.homepage", "about:blank");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("doh-rollout.disable-heuristics", true);
user_pref("extensions.formautofill.creditCards.enabled", false);
user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
user_pref("network.trr.mode", 5);
user_pref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");
user_pref("signon.rememberSignons", false);
}
end
