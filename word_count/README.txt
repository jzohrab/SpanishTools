# Word counter

Create your own `ignore.txt` in the same folder as `word_counter.rb`,
and add words you want to ignore.

Run `word_counter.rb` from the command line, specifying the text file
whose text you want to count.  Example:

```
$ ruby word_counter.rb ~/Dropbox/org/el_hobbit.org
```

This creates two files: one with raw processed data, and another file
where the code attempts to group like words.  Sample output:

```
MacBook-Air:word_count jeff$ ruby word_counter.rb ~/Dropbox/org/el_hobbit.org
Found 66800 words ...
Processing 53114 words, ignoring words in ignore.txt ...
 ... 1000 of 53114
 ... 2000 of 53114
 [SNIP]
 ... 52000 of 53114
 ... 53000 of 53114
Done.
Wrote Dropbox/org/el_hobbit.org.frequency.RAW.txt, 10299 words
Grouping like words where possible ...
 ... 1000 groups, 8744 words remaining
 ... 2000 groups, 7180 words remaining
 [SNIP]
 ... 6000 groups, 931 words remaining
 ... 6542 groups, 0 words remaining
Wrote Dropbox/org/el_hobbit.org.frequency.COMPRESSED.txt, 6542 word groups
```

## Generated files

### Raw file

el_hobbit.org.frequency.RAW.txt, sample:


```
00546|había
00485|dijo
00483|como
00370|era
00336|enanos
...
```

Fields, separated by '|':

* 1: the raw count of the word
* 2: the word itself

### Compressed file

el_hobbit.org.frequency.COMPRESSED.txt

The code attempts to group like words together, so this file is smaller than the RAW file.  Sample:

```
00775|había|había,habíamos,habían,habías
00574|toda|toda,todas,todo,todos
00568|estaba|estaba,estabais,estaban,estabas,estad,estado,estamos,estar,estaremos,estaría,estemos,esto,esté
00526|come|come,comemos,comen,comer,comeremos,comerlas,comido,comieron,como
```

Fields:

* 1: the total count of the "word group"
* 2: a sample word (the shortest) from the word group
* 3: all the words forming the word group

#### Notes on the "compression"

The code does simple word-termination comparisions to determine if two words have a similar root.  This is reasonable as a first iteration for this project, but it's not really accurate.  Some examples from El Hobbit that show the inaccuracy:

```
# "sobre" is not related to "sobra"
00249|sobra|sobra,sobraría,sobras,sobre

# These three words have nothing to do with each other!
00166|tan|tan,tas,ten

# These are all forms of the verb "ser" ... except for "ero" (?),
# and 'sea' may also be a noun ...
00522|era|era,eran,eras,eres,ero
00057|sea|sea,seamos,sean,seas
```

On the other hand, the code does do a decent job of grouping many other things:

```
00196|entraba|entraba,entraban,entrad,entrado,entran,entrando,entrar,entraron,entrase,entre,entremos,entró
00194|baja|baja,bajaba,bajaban,bajad,bajado,bajamos,bajando,bajar,bajaran,bajare,bajaron,bajas,bajo,bajos
00173|hubiera|hubiera,hubierais,hubieran,hubieras,hubiese,hubieseis,hubiesen,hubieses,hubo
00148|llega|llega,llegaba,llegaban,llegado,llegamos,llegan,llegando,llegar,llegara,llegaremos,llegaron,llegase,llegasen,llegó
```

