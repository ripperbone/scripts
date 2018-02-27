#!/usr/bin/env ruby

`git branch`.split("\n").each do |branch|
  next if branch.strip.include? '*' or branch.strip.include? 'master'
  puts "git branch -d #{branch.strip}"
  system("git branch -d #{branch.strip}")
end
