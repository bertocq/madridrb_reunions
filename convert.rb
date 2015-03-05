require 'nokogiri'
require 'open-uri'
require 'json'

# spinner on the console, just 4 the lulz (http://stackoverflow.com/a/10263337)
def show_wait_spinner(fps=10)
  chars = %w[| / - \\]
  delay = 1.0/fps
  iter = 0
  spinner = Thread.new do
    while iter do  # Keep spinning until told otherwise
      print chars[(iter+=1) % chars.length]
      sleep delay
      print "\b"
    end
  end
  yield.tap{       # After yielding to the block, save the return value
    iter = false   # Tell the thread to exit, cleaning up after itself…
    spinner.join   # …and wait for it to do so.
  }                # Use the block's return value as the method's
end

# if reunions.txt doesn't exist, read content from interwebz and store it
def read_reunions_list force_download
  reunions_file = './reunions.txt'
  if force_download || !File.exist?(reunions_file)
    puts 'Accesing https://madridrb.jottit.com/?m=edit'
    show_wait_spinner{
      reunions_list = ''
      doc = Nokogiri::HTML(open('https://madridrb.jottit.com/?m=edit'))
      content = doc.css('#content_text').map(&:text)
      content[0].to_s.scan(/\* \*(.*?)$/).each do |line|
        reunions_list << line[0]+"\n"
      end
      File.write(reunions_file, reunions_list)
    }
    puts "Content retrieved and stored on #{reunions_file}"
  end
  File.open(reunions_file).read
end

# compose the link to get the reunion data un markdown
def compose_link line
  'https://madridrb.jottit.com/' + line.downcase.sub(' ', '_') + '?m=edit'
end

# returns a hash with the name and twitter url for a given speaker link
def compose_speaker speaker
  { name: speaker[/\[?(.*?)\]/, 1], twitter: speaker[/\((.*?)\)?$/, 1] }
end

# compose speaker list
def set_speakers speakers
  speakers_regex = /\[(.*?)\) y \[(.*?)\)$/
  # if there is multiple speakers
  speakers = speakers[speakers_regex, 0]  ? [speakers[speakers_regex, 1], speakers[speakers_regex, 2]]
                                          : [speakers]
  # compose each speakers data
  speakers.map! { |speaker| compose_speaker(speaker.to_s) }
end


force_download = ARGV[0] == '-d'

# read list of reunions
text = read_reunions_list force_download

# make some format corrections
text.gsub!(/\r\n?/, '\n')
text.gsub!(/“|”/, '"')
text.gsub!(/–/, '-')
text.gsub!('<br/>', '')

reunions = {}

# lets gather each reunion's data
text.each_line do |line|
  case line
    when /[0-9]{4}\]\(.*?\)/ # There is a link on the title
      link = line[/[0-9]{4}\]\((.*?)\)/, 1]
      # If there is no 'http' its an internal link
      link = compose_link link unless link[/http/, 0]

    when /\[\[.*?\]\]/ # The link is the title itself
      link = compose_link line[/\[\[(.*?)\]\]/, 1]
  end

  date  = line[/\*\*(.*?)\*\*/, 1]
  month = line[/\[(.+) ([0-9]{4})\]/,  1].sub('[', '')
  year  = line[/\[(.+) ([0-9]{4})\]/, 2]

  topics = []
  topics_regex = /- \"(.*? con \[.*?\)) y \"(.*? con \[.*?\))$/
  
  topics = line[topics_regex, 0]  ? [line[topics_regex, 1], line[topics_regex, 2]] # there are multiple topics
                                  : [line[/- \"(.*?)$/, 1]]

  # for each topic get the title and speakers
  topics.map! do |topic|
    title     = topic[/(.*?)\"/, 1]
    speakers  = topic[/\", con (.*?)$/, 1].to_s
    
    speakers  = speakers.empty? ? nil : set_speakers(speakers)
          
    { title: title, speakers: speakers }
  end

  # get reunion markdown data
  if link[/madridrb.jottit.com/, 0] && link.ascii_only? # if its an internal link in ascii
    # txt file for each reunion
    file = "./reunions/#{month}_#{year}.txt"
    if force_download || !File.exist?(file)
      show_wait_spinner{
        puts "Getting content from #{link}"
        # visit the url and get the content in markdown
        doc = Nokogiri::HTML(open(link))
        content = doc.css('#content_text').map(&:text)
        puts "Writting file #{file}"
        File.write(file, content[0])
      }
    end
  end

  reunions[month + '_' + year] = { link: link, date: date, month: month,
                                   year: year, topics: topics, file: file || nil }
end



# write json file with all gathered data
#puts 'Writting ./reunions.json'
#File.write('./reunions.json', reunions.to_json)


def parse_file(reunions,file)
  text = File.open("./reunions/#{file}.txt").read

  # obtain and clean additional data
  text.gsub!('<br/>', '')

  # LOCATION
  location_regex = /\*\*Lugar:\*\* (.*?)$/
  location = text[location_regex, 1]
  text.gsub!(/#{Regexp.quote(text[location_regex, 0])}\n*/, '')

  # delete date
  date_regex = /\*\*Fecha:\*\* (.*?)$/
  if text[date_regex, 0] then text.gsub!(/#{Regexp.quote(text[date_regex, 0])}\n*/, '') end

  # delete hour
  hour_regex = /^\*\*Hora:\*\* (.*?)$/
  text.gsub!(/#{Regexp.quote(text[hour_regex, 0])}\n*/, '')

  # TOPICS => VIDEO_URL
  #video_link = text[/\(http:\/\/vimeo.com\/(.*?)\)/, 0].to_s.gsub!(/\(|\)/,'')
  #puts video_link

  # delete topic name
  title_regex = /\# #{Regexp.quote(reunions[file][:topics][0][:title])} (.*?)$\n*/
  text.gsub!(title_regex, '')
  #title_regex = /\# #{reunions[file][:topics][0][:title]} (.*?)$/
  #text.gsub!(/#{Regexp.quote(text[title_regex, 0])}\n*/, '')
  #SPONSORS

  # PARTICIPANTS
  # participants = text[/@(.*?)$/, 1].to_s
  #  puts 'PARTICIPANTS: ' + participants + "\n\n"

  # DESCRIPTION
  description = text

  #puts text[/### Resources(.*?)### Asistentes/m,1]
  #puts text[/### Asistentes(.*?)/m,1]
  #puts text[/\* @(.*?)?/m,1]

  puts text
end

parse_file(reunions,'Diciembre_2010')