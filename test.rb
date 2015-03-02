gem 'nokogiri'
require 'nokogiri'
require 'open-uri'

#compone un link para obtener el contenido de una charla
def composeLink (line)
	'https://madridrb.jottit.com/' + line.downcase.sub(' ','_') + '?m=edit'
end

#leemos y limpiamos el fichero
text=File.open('reunions.txt').read
text.gsub!(/\r\n?/, "\n")
text.gsub!(/“|”/,'"')
text.gsub!(/–/,'-')

reunions = Array.new

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

	if link[/madridrb.jottit.com/,0] && link.ascii_only? #si es un link interno (en ascii)
		#visitamos el link
		doc = Nokogiri::HTML(open(link))
		content = doc.css('#content_text').map(&:text)
		
		#guardamos el contenido
		File.write("./reunions/#{month}_#{year}.md", content)
	end
	reunions.push({:link => link, :date => date, :month => month, :year => year, :title => title, :file => '#{month}_#{year}.md'})
end

#puts reunions

