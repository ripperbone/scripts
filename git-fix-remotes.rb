#!/usr/bin/env ruby
# frozen_string_literal: true

# Find all git repositories below the current working directory. List the configured remotes. If
# any match a pattern, set the url to a replacement.

def github_https_to_ssh(name, url)
   return unless %r{https://github.com/(.*)/(.*)}.match url

   new_url = "git@github.com:#{Regexp.last_match(1)}/#{Regexp.last_match(2)}"
   puts "URL is #{url} --> #{new_url}"
   #puts "[DRY RUN] git remote set-url #{name} #{new_url}"
   `git remote set-url #{name} #{new_url}`

   return unless name.eql? 'origin'

   `git remote rename origin github`
end

Dir.glob("**/.git") do |file|
   Dir.chdir(File.dirname(file)) do
      puts "Found git repository in #{Dir.pwd}"
      `git remote -v`.split("\n").each do |remote|
         remote_parts = remote.split
         name = remote_parts[0]
         url = remote_parts[1]
         push_or_fetch = remote_parts[2]

         if push_or_fetch.gsub(/[()]/, "").eql? "push"
            next # just care about the 'fetch' url
         end

         github_https_to_ssh(name, url)

      end
   end
end
