#!/usr/bin/env ruby
# frozen_string_literal: true

require 'erb'
require 'tempfile'
require 'optparse'


# Print addresses to an envelope so you can mail a letter.
#
# Run with:
#   ./print_envelope.rb [options]
#


def template
   return ERB.new <<-TEMPLATE
 <%= from_name %>
 <%= from_address_line_1 %>
 <%= from_address_line_2 %>




                                                           <%= to_name %>
                                                           <%= to_address_line_1 %>
                                                           <%= to_address_line_2 %>
   TEMPLATE
end

options = {
   :copies => 1,
   :from_name => nil,
   :from_address_line_1 => nil,
   :from_address_line_2 => nil,
   :to_name => nil,
   :to_address_line_1 => nil,
   :to_address_line_2 => nil
}
OptionParser.new do |opts|
   opts.on("-c NUM", "--copies", Integer, "Specify number of copies") do |v|
      options[:copies] = v
   end
   opts.on("--from-name STRING") do |v|
      options[:from_name] = v
   end
   opts.on("--from-address-line-1 STRING") do |v|
      options[:from_address_line_1] = v
   end
   opts.on("--from-address-line-2 STRING") do |v|
      options[:from_address_line_2] = v
   end
   opts.on("--to-name STRING") do |v|
      options[:to_name] = v
   end
   opts.on("--to-address-line-1 STRING") do |v|
      options[:to_address_line_1] = v
   end
   opts.on("--to-address-line-2 STRING") do |v|
      options[:to_address_line_2] = v
   end
end.parse!


file = Tempfile.new(File.basename(__FILE__))
file.write(template.result_with_hash(options))
file.close


puts File.read(file.path)

# Send to printer.
options[:copies].times do
   puts "enscript --landscape --font Helvetica@14 --no-header --media Env10 #{file.path}"
   system("enscript --landscape --font Helvetica@14 --no-header --media Env10 #{file.path}")
end

puts "done."
