#!/usr/bin/env ruby
# frozen_string_literal: true


# Set screen saver message to output of `fortune` command

def formatted_fortune
   `/usr/local/bin/fortune -s`.gsub(/\n/, ' ').gsub(/[^0-9a-zA-Z .'!,-?]/, '')
end


message = formatted_fortune
puts message
system("defaults -currentHost write com.apple.ScreenSaver.Basic MESSAGE \"#{message}\"")
# Apply changes
# killall cfprefsd
