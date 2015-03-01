# madridrb_reunions
Scripts to convert the old reunions wiki data to json

Executing test.rb you can see quick test to scrap the data form https://madridrb.jottit.com for parsing later:

1. Accesing https://madridrb.jottit.com/?m=edit we can get the markdown version of the front page and manually save to reunions.txt the list (beware  Junio 2014 line it's not with the all the rest)

2. For each line we try to get all the possible data and store in an array of hashes {:date, :month, :year, :title, :speaker, :link} 
**WORK IN PROGRESS**, *still need to figure out how to get all the titles and speakers correctly*

3. Since we stored the internal links (there are some externals) with the ?m=edit option, we can access the markdown version of each reunion and store in a mont_year.md file the contents under /reunions directory (**WORK IN PROGRESS** Currently the url https://madridrb.jottit.com/f%C3%BAtbol.rb_julio_2011 gives an error because the non-ascii character, content needs to be retrieved manually)

What's next:

4. Parse each file's data and store it in JSON/YAML.




