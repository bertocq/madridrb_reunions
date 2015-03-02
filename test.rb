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
  	
  	when /[0-9]{4}\]\(.*?\)/ #There is a link on the title
  		link = line[/[0-9]{4}\]\((.*?)\)/,1]
  		#If there is no 'http' its an internal link
  		link = compose_link link unless link[/http/,0]
  	
  	when /\[\[.*?\]\]/ #The link is the title itself
  		link = compose_link line[/\[\[(.*?)\]\]/,1]

	end

  	date = line[/\*\*(.*?)\*\*/,1]
	month = line[/\[(.+) ([0-9]{4})\]/,1].sub("[","")
	year = line[/\[(.+) ([0-9]{4})\]/,2]
	
	topics = []
	topics_regex = /- \"(.*? con \[.*?\)) y \"(.*? con \[.*?\))$/
	if line[topics_regex,0] #there are multiple topics
		topics = [line[topics_regex,1], line[topics_regex,2]]
	else
		topics = [line[/- \"(.*?)$/,1]]
	end		

	#for each topic get the title and speakers
	topics.map! do |topic|
		title = topic[/(.*?)\"/,1]
		speakers = topic[/\", con (.*?)$/,1].to_s

		if speakers.empty?
			speakers = nil
		else
			speakers_regex = /\[(.*?)\) y \[(.*?)\)$/
			#if there is multiple speakers
			if speakers[speakers_regex,0] 
				speakers = [speakers[speakers_regex,1],speakers[speakers_regex,2]]
			else
				speakers = [speakers]
			end
			#compose each speakers data
			speakers.map! {|speaker| compose_speaker(speaker.to_s) } 
		end

		{:title => title, :speakers => speakers}
	end

	#get reunion markdown data
	if link[/madridrb.jottit.com/,0] && link.ascii_only? #if its an internal link (en ascii)
		#visit the url and get the content in markdown
		doc = Nokogiri::HTML(open(link))
		content = doc.css('#content_text').map(&:text)
		
		#write a file for the reunion
		file = "#{month}_#{year}.md"
		File.write("./reunions/#{file}", content)
	end

	reunions[month+"_"+year] = {:link => link, :date => date, :month => month, :year => year, :topics => topics, :file => file||nil}
end

#write json file with all gathered data	
File.write("./reunions.json", reunions.to_json)


