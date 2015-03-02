# madridrb_reunions
##Script to convert the old reunions wiki data (https://madridrb.jottit.com) to json

Steps made:

1. Accesing https://madridrb.jottit.com/?m=edit we can get the markdown version of the front page and manually save to reunions.txt the list (beware  Junio 2014 line it's not with the all the rest), making some minor tweaks to the format of some lines it will be ready for the parsers. Stored in **reunions.txt**

2. Parse every line for some data: {:link, :date, :month, :year, :title, :speakers _(array because sometimes there are two)_, :file _(with month_year.md format)_}. Save in **reunions.json** all the retrieved data.

3. Visit every _(internal)_ link with the ?m=edit option to access the markdown version of the reunion, and store the content in the correspondent mont_year.md file under **./reunions** directory _(the file for the link https://madridrb.jottit.com/f%C3%BAtbol.rb_julio_2011 needs to be retrieved manually because the non-ascii character)_




