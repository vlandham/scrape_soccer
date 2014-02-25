#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'json'

URL = "http://www.soccerbase.com/teams/team.sd?team_id=740&teamTabs=transfers&season_id="

MAX_SEASON = 143
MIN_SEASON = 51

MAX_YEAR = 2014

def parse_table(table)
  data = []
  headers = table.css("thead tr th").collect {|h| h.text.strip}
  puts headers.inspect
  rows = table.css("tbody tr")
  rows.each do |row|
    values = row.css("td").collect {|v| v.text.strip}
    d = Hash[headers.zip(values)]
    data << d
  end
  data
end


all_data = []
MAX_SEASON.downto(MIN_SEASON).each do |season|
  puts season

  url = URL + season.to_s
  page = Nokogiri::HTML(open(url))
  headers = page.css(".headlineBlock")
  values = {} 
  headers.each do |header|
    title = header.css("h2,h3").text
    puts title
    table = header.search("~ table")[0]
    data = parse_table(table)
    values[title.strip] = data
    # puts table.inspect
  end

  entry = {}
  entry["season"] = season
  entry["start_year"] = 2014 - (MAX_SEASON - season)
  entry["end_year"] = 2014 - (MAX_SEASON - (season - 1))
  entry["data"] = values

  all_data << entry
  # break
end

output_filename = "transfers.json"
File.open(output_filename, 'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(all_data.to_json))
end


