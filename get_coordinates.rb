require 'json'
require 'geocoder'

Geocoder.configure do |config|
  config.lookup = :google
  config.timeout = 5
end

file = File.open("applicant_locations.json", "rb")
locations = JSON.parse file.read
locations_cache = {}

file_content = "var coords = ["
locations.each do |loc|
  if locations_cache[loc]
    res = locations_cache[loc]
    puts "Using cache: " + loc
  else
    res = Geocoder.search(loc).first
    puts "Cache miss"
    
    sleep(0.25) #don't hit rate limit on the API
    locations_cache[loc] = res
  end
  file_content << "{lng: #{res.longitude}, lat: #{res.latitude}, school: \"#{loc}\"}," if res
end

file_content = file_content.chomp[0..-2] #remove trailing comma

file_content << "]"

File.open("output.js", 'w') { |file| file.write(file_content) }