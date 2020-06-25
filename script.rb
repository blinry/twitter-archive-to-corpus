require "json"
require "cgi"

js = File.read("tweet.js")
json = js[25..-1]
json = JSON.parse(json)

json.select! do |j|
  j["tweet"]["lang"] == "en"
end

tweets = json.map do |j|
  urls = j["tweet"]["entities"]["urls"]
  urls_lookup = {}
  urls.each do |u|
    urls_lookup[u["url"]] = u["expanded_url"]
  end
  j["tweet"]["full_text"].gsub(/https?:\/\/t.co\/\w+/) do |u|
    urls_lookup[u] || "[media]"
  end
end

tweets.select! do |t|
  # Drop tweets that are RTs or replies to other people.
  not t =~ /^RT / and not(t =~ /^@/ and not t =~ /^@blinry /)
end

tweets.map! do |t|
  # Unescape HTML entities.
  t = CGI.unescapeHTML(t)

  # Because we only want top-level tweets, remove the mentions from longer threads.
  t = t.gsub(/^@blinry /, "")

  # Mask mentions and hashtags with a word joiner, U+2060.
  t = t.gsub(/@/, "@⁠")
  t = t.gsub(/#/, "#⁠")
end

tweets.shuffle!

tweets.each do |t|
  puts "<|startoftext|>#{t}<|endoftext|>"
end
