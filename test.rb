gem 'nokogiri'
require 'nokogiri'
require 'open-uri'
require 'json'

#compose the link to get the reunion data un markdown
def compose_link (line)
	'https://madridrb.jottit.com/' + line.downcase.sub(' ','_') + '?m=edit'
end

#returns a hash with the name and twitter url for a given speaker link
def compose_speaker (speaker)
	{:name => speaker[/\[?(.*?)\]/,1], :twitter => speaker[/\((.*?)\)?$/,1]}
end

#read and clean format of the file
text=File.open('reunions.txt').read
text.gsub!(/\r\n?/, "\n")
text.gsub!(/“|”/,'"')
text.gsub!(/–/,'-')
text.gsub!("<br/>","")

reunions = {}

text.each_line do |line|
	case line

  	#There is a link on the title
  	when /[0-9]{4}\]\(.*?\)/
  		link = line[/[0-9]{4}\]\((.*?)\)/,1]
  		#If there is no 'http' its an internal link
  		unless link[/http/,0] then link = compose_link link end
  	#The link is the title itself
  	when /\[\[.*?\]\]/
  		link = compose_link line[/\[\[(.*?)\]\]/,1]
	end

  	date = line[/\*\*(.*?)\*\*/,1]
	month= line[/\[(.+) ([0-9]{4})\]/,1].sub("[","")
	year= line[/\[(.+) ([0-9]{4})\]/,2]
	title = line[/- \"(.*?)\"/,1]
	speakers = [line[/\", con (.*?)$/,1]]

	#if there is multiple speakers
	if speakers.to_s[/(.*?)\) y \[(.*?)/,0] 
		speakers = [speakers.to_s[/(.*?)\) y \[(.*?)$/,1], speakers.to_s[/(.*?)\) y \[(.*?)$/,2]]
	end

	#compose each speakers data
	speakers.map! {|speaker| compose_speaker(speaker.to_s) } 

	if link[/madridrb.jottit.com/,0] && link.ascii_only? #if its an internal link (en ascii)
		#visit the url and get the content in markdown
		doc = Nokogiri::HTML(open(link))
		content = doc.css('#content_text').map(&:text)
		
		#write a file for the reunion
		file = "#{month}_#{year}.md"
		File.write("./reunions/#{file}", content)
	end

	reunions[month+"_"+year] = {:link => link, :date => date, :month => month, :year => year, :title => title, :speakers => speakers, :file => file||nil}
end

#write json file with all gathered data	
File.write("./reunions.json", reunions.to_json)


