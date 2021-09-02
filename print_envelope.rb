#!/usr/bin/env ruby
# frozen_string_literal: true

require 'erb'
require 'tempfile'
require 'optparse'
require 'json'


# Print addresses to an envelope so you can mail a letter.
#
# Run with:
#   ./print_envelope.rb --from-name "Your Name' --from-address-line1 "1234 Some Street" ...
#
# or read from a JSON file:
#   ./print_envelope.rb --json-file ~/path/to/file.json


def template
   return ERB.new <<-TEMPLATE
 <%= from_name %>
 <%= from_address_line1 %>
 <%= from_address_line2 %>




                                                           <%= to_name %>
                                                           <%= to_address_line1 %>
                                                           <%= to_address_line2 %>
   TEMPLATE
end

options = {
   copies: 1,
   from_name: nil,
   from_address_line1: nil,
   from_address_line2: nil,
   to_name: nil,
   to_address_line1: nil,
   to_address_line2: nil,
   dry_run: false
}
OptionParser.new do |opts|
   opts.on("-c NUM", "--copies", Integer, "Specify number of copies") do |v|
      options[:copies] = v
   end
   opts.on("--from-name STRING") do |v|
      options[:from_name] = v
   end
   opts.on("--from-address-line1 STRING") do |v|
      options[:from_address_line1] = v
   end
   opts.on("--from-address-line2 STRING") do |v|
      options[:from_address_line2] = v
   end
   opts.on("--to-name STRING") do |v|
      options[:to_name] = v
   end
   opts.on("--to-address-line1 STRING") do |v|
      options[:to_address_line1] = v
   end
   opts.on("--to-address-line2 STRING") do |v|
      options[:to_address_line2] = v
   end
   opts.on("--json-file STRING") do |v|
      if File.exist?(v)
         json_data = JSON.parse(File.read(v), symbolize_names: true)
         options = options.merge(json_data)
      else
         puts "JSON file not found!"
         exit(1)
      end
   end
   opts.on("--dry-run", TrueClass, "do not send to printer") do |v|
      options[:dry_run] = v
   end


end.parse!


file = Tempfile.new(File.basename(__FILE__))
file.write(template.result_with_hash(options))
file.close


puts File.read(file.path)


exit(0) if options[:dry_run]

# Send to printer.
options[:copies].times do
   puts "enscript --landscape --font Helvetica@14 --no-header --media Env10 #{file.path}"
   system("enscript --landscape --font Helvetica@14 --no-header --media Env10 #{file.path}")
end

puts "done."
