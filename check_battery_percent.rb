#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'optparse'

# Checks the battery status of the keyboard

def keyboard_device_name
   `upower -e`.split("\n").find { |device| device.include? 'keyboard' }
end

def mouse_device_name
   `upower -e`.split("\n").find { |device| device.include? 'mouse' }
end

def battery_status(device_name)
   `upower -i #{device_name}`.split("\n")
                             .select { |it| it.include? ":" }
                             .map { |it| [it.split(':')[0].strip, it.split(':')[1].strip] }.to_h
end

def pretty_hash(hash, indent = 0)
   output = +''
   hash.each do |key, val|
      if val.is_a?(Hash)
         output << "#{' ' * indent}#{key}:\n"
         output << pretty_hash(val, indent += 5)
      else
         output << "#{' ' * indent}#{key}: #{val}\n"
      end
   end
   return output
end

options = {}
parser = OptionParser.new do |opts|
   opts.on('--json', TrueClass, "Output results as JSON") do |v|
      options[:json] = v
   end
end
parser.parse!

results = {}
results["keyboard"] = battery_status(keyboard_device_name).slice("model", "percentage") unless keyboard_device_name.nil?
results["mouse"] = battery_status(mouse_device_name).slice("model", "percentage") unless mouse_device_name.nil?

puts options[:json] ? JSON.pretty_generate(results) : pretty_hash(results)
