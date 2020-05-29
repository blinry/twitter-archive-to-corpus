require "json"

#csv = IO.readlines "tweets.csv"
#p csv.size

js = File.read("tweet.js")
json = js[25..-1]
json = JSON.parse(json)

langs = json.map do |j|
  j["tweet"]["lang"]
end

#p langs.group_by{|e| e}.map{|k, v| [k, v.length]}.to_h

json = json.select do |j|
  j["tweet"]["lang"] == "en"
end

tweets = json.map do |j|
  j["tweet"]["full_text"]
end

tweets = tweets.select do |t|
  not t =~ /^RT / and not t =~ /^@/
end

tweets.each do |t|
  print "<|startoftext|>"
  print t
  print "<|endoftext|>\n"
end
