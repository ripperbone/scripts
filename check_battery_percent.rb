#!/usr/bin/env ruby
# frozen_string_literal: true

# Checks the battery status of the keyboard

def keyboard_device_name
   `upower -e`.split("\n").find { |device| device.include? 'keyboard' }
end

def battery_status(device_name)
   `upower -i #{device_name}`.split("\n")
                             .select { |it| it.include? ":" }
                             .map { |it| [it.split(':')[0].strip, it.split(':')[1].strip] }.to_h
end


puts battery_status(keyboard_device_name)['percentage']
