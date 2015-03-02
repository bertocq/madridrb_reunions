gem 'nokogiri'
require 'nokogiri'
require 'open-uri'
require 'json'

#compone un link para obtener el contenido de una charla
def composeLink (line)
	'https://madridrb.jottit.com/' + line.downcase.sub(' ','_') + '?m=edit'
end
#devuelve un hash con el nombre y el twitter de un speaker
def composeSpeaker (speaker)
	{:name => speaker[/\[?(.*?)\]/,1], :twitter => speaker[/\((.*?)\)?$/,1]}
end
#leemos y limpiamos el fichero
text=File.open('reunions.txt').read
text.gsub!(/\r\n?/, "\n")
text.gsub!(/“|”/,'"')
text.gsub!(/–/,'-')
text.gsub!("<br/>","")

reunions = {}

text.each_line do |line|
	case line
  	# existe link (miramos que tenga año para no coger links de twitter u otros)
  	when /[0-9]{4}\]\(.*?\)/
  		link = line[/[0-9]{4}\]\((.*?)\)/,1]
  		#si no tiene http delante es un link interno
  		unless link[/http/,0] then link = composeLink link end
  	# el link es el titulo
  	when /\[\[.*?\]\]/
  		link = composeLink line[/\[\[(.*?)\]\]/,1]
	end

  	date = line[/\*\*(.*?)\*\*/,1]
	month= line[/\[(.+) ([0-9]{4})\]/,1].sub("[","")
	year= line[/\[(.+) ([0-9]{4})\]/,2]
	title = line[/- \"(.*?)\"/,1]
	speakers = line[/\", con (.*?)$/,1]
	if speakers.to_s[/(.*?)\) y \[(.*?)/,0] #si hay varios speakers, los separamos en un array
		speakers = [composeSpeaker(speakers.to_s[/(.*?)\) y \[(.*?)$/,1]), composeSpeaker(speakers.to_s[/(.*?)\) y \[(.*?)$/,2])]
	else
		speakers = [composeSpeaker(speakers.to_s)]
	end

	if link[/madridrb.jottit.com/,0] && link.ascii_only? #si es un link interno (en ascii)
		#visitamos el link
		doc = Nokogiri::HTML(open(link))
		content = doc.css('#content_text').map(&:text)
		
		#guardamos el contenido
		File.write("./reunions/#{month}_#{year}.md", content)
		file = "#{month}_#{year}.md"
	end

	reunions[month+"_"+year] = {:link => link, :date => date, :month => month, :year => year, :title => title, :speakers => speakers, :file => file||nil}
end

#escribimos el fichero con los datos básicos de las reuniones		
File.write("./reunions.json", reunions.to_json)


