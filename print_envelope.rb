#!/usr/bin/env ruby

require 'erb'
require 'tempfile'


# Print addresses to an envelope so you can mail a letter.
#
# Run with:
#   ./print_envelope.rb
#
# Or create a file containing the responses 1 per line. Then do:
#   cat /path/to/file | ./print_envelope.rb


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


properties_hash = {
   'from_name' => nil,
   'from_address_line_1' => nil,
   'from_address_line_2' => nil,
   'to_name' => nil,
   'to_address_line_1' => nil,
   'to_address_line_2' => nil
}


properties_hash.each_key do |key|
   print "#{key.gsub('_', ' ').upcase}? " if STDIN.tty?
   properties_hash[key] = gets.chomp
end



file = Tempfile.new(File.basename(__FILE__))
file.write(template.result_with_hash(properties_hash))
file.close


puts File.read(file.path)

#exit(0)

# Send to printer.
system("enscript --landscape --font Helvetica@14 --no-header --media Env10 #{file.path}")

puts "done."
