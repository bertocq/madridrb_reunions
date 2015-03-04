# madridrb_reunions
##Script to convert the old reunions wiki data (https://madridrb.jottit.com) to json

In console
```
ruby test.rb
```

1. Reads the content from https://madridrb.jottit.com/?m=edit and gets only the list of reunions, then writes it to a file *reunions.txt* (if it exists already then skips this step).

2. Parses each line for some data: {:link, :date, :month, :year, :title, :speakers [{:name, :twitter}], :file } and saves all into **reunions.json**.

3. Visit every _(internal)_ link with the ?m=edit option to access the markdown version of the reunion, and store the content in the correspondent mont_year.txt file under **./reunions** directory _(the file for the link https://madridrb.jottit.com/f%C3%BAtbol.rb_julio_2011 needs to be retrieved manually because the non-ascii character)_


To force the download of data from jottit.com overwriting existing files use:

```
ruby test.rb -d
```

