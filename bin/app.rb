# frozen_string_literal: true

require "optparse"
require "yt/sub"

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: app.rb [options]"
  options[:verbose] = false

  opts.on("--version", "show version") do
    puts Yt::Sub::VERSION
    exit 0
  end

  opts.on("-v", "--verbose", "be verbose") do
    options[:verbose] = true
  end

  opts.on("-l", "--language LANGUAGE", "Language of FILE") do |language|
    options[:language] = language
  end

  opts.on("-f", "--file FILE", "Upload .srt file, FILE") do |file|
    options[:file] = file
  end

  opts.on("-i", "--video-id ID", "Video ID of FILE") do |video_id|
    options[:video_id] = video_id
  end
end
optparse.parse!

app = Yt::Sub::App.new(file: options[:file], language: options[:language],
                       video_id: options[:video_id], verbose: options[:verbose])
app.upload
