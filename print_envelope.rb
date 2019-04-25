#!/usr/bin/env ruby

require 'erb'
require 'yaml'
require 'tempfile'


# Print addresses to an envelope so you can mail a letter.

def template
   return ERB.new <<-eos
 <%= from_name %>
 <%= from_address_line_1 %>
 <%= from_address_line_2 %>




                                                           <%= to_name %>
                                                           <%= to_address_line_1 %>
                                                           <%= to_address_line_2 %>
   eos
end

def usage
   puts <<-eos

      usage: #{File.basename(__FILE__)} /path/to/properties.yaml

      from_name:
      from_address_line_1:
      from_address_line_2:
      to_name:
      to_address_line_1:
      to_address_line_2:

   eos
end


properties_hash = {}

if ARGV.size.eql? 1 and File.exists?(ARGV.first)
   properties_hash = YAML.load(File.read(ARGV.first))
else
   usage
   exit(1)
end


file = Tempfile.new(File.basename(__FILE__))
file.write(template.result_with_hash(properties_hash))
file.close


puts File.read(file.path)


# Send to printer.
system("enscript --landscape --font Helvetica@14 --no-header --media Env10 #{file.path}")

puts "done."
