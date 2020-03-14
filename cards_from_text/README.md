A set of scripts to generate cards:

* vocabulary (flashcards with sentences, definitions, images, etc.)
* cloze (simple cloze cards)
* verb conjugations (flashcards with verb roots, conjugation table, etc.)
* listening comprehension (cards with sentences created using Amazon Polly)

# Vocabulary flashcards

Given a text file with some Spanish, e.g:

*sample.txt*

```
Un astuto zorro oyó de repente el lejano canto de un gallo.
```

You edit this text, adding asterisks to mark words you don't know:

```
Un astuto* zorro oyó de repente el lejano canto de un gallo*.
```

You then run scripts generate a pipe-delimited ("|") file containing the
following fields:

* the word root (e.g., the root of "hablabamos" is "hablar")
* the original text, with the marked word replaced with a blank
* the original text, with the marked word highlighted in red
* an HTML link to search for a picture (this can be clicked in the
  Anki browser window)
* a definition from es.thefreedictionary.com, which you select during
  processing
* an HTML link to search for a recording on forvo.com (can be clicked
  in the Anki browser)


## Steps to create the final file

### 1. Add asterisks

Add asterisks after unknown words, or around unknown phrases (here,
_astuto_, _de repente_, and _gallo_):

```
Un astuto* zorro oyó *de repente* el lejano canto de un gallo*.
```

#### 1 b.  Optional: add '[' and ']' around paragrahs that should remain together in generated cards.

For example, the following would generate two cards of one sentence each:

```
Un astuto* zorro oyó un ruido.
Fue el lejano canto de un gallo*.
```

But this will generate one card, containing both sentences grouped together:

```
[
Un astuto* zorro oyó un ruido.
Fue el lejano canto de un gallo*.
]
```

This is useful for providing more context, or more interesting text snippets.

#### 1 c.  Optional: add '|' after the word, and the root form, to force lookup to work.

Some things can't be looked up easily (for example, "me caigo") ... If
you know the root form, you can specify it.  E.g.:

```
Yo *me caigo|caerse*.
```

### 2. Run `build_source.rb`

This utility looks up definitions in es.thefreedictionary.com, which
handles things like verb declensions, etc., and generates a .yaml file.

```
$ ruby build_source.rb sample.txt 
  ... astuto (1 of 2)
  ... gallo (2 of 2)
Generated sample.txt.yaml.
(verified ok)
```

### 3. Edit the generated yaml file to choose the final definitions

The generated sample.txt.yaml file looks like this:

```
- :word: astuto
  :sentence: Un astuto zorro oyó el lejano canto de un gallo.
  :root: astuto
  :definitions:
  - adj. Que tiene habilidad e ingenio para engañar, para evitar que le engañen, o para conseguir cualquier propósito. (sagaz, pícaro)cándido
  :index: 1 of 2
  :core: true


- :word: gallo
  :sentence: Un astuto zorro oyó el lejano canto de un gallo.
  :root: gallo
  :definitions:
  - s. m. ZOOLOGÍA Ave galliforme doméstica, ...
  - ZOOLOGÍA Pez marino comestible, de cuerpo comprimido, ...
  ... [snip, removed lots of definitions] ...
  - Perú Orinal de cama especial para hombres.
  - zoología  ave doméstica de cresta roja y alta
  :index: 2 of 2
  :core: false
```

Note that "core: true" means the word is part of the core 5000 words,
and so should be treated as higher priority.  If you want to skip
learning low-priority words, you can delete them from the yaml file,
or move them to a separate file for later processing.

The definition for "astuto" looks good as a starting point.  There are
multiple definitions for "gallo".  Delete all definitions that don't
seem right, and edit anything you don't like:


```
- :word: astuto
  :sentence: Un astuto zorro oyó el lejano canto de un gallo.
  :root: astuto
  :definitions:
  - adj. Que tiene habilidad e ingenio para engañar / conseguir cualquier propósito. (sagaz, pícaro)
  :index: 1 of 2
  :core: true


- :word: gallo
  :sentence: Un astuto zorro oyó el lejano canto de un gallo.
  :root: gallo
  :definitions:
  - ave doméstica de cresta roja y alta
  :index: 2 of 2
  :core: false
```

### 4. Generate the cards from the edited yaml

```
$ ruby gen_cards.rb sample.txt.yaml 
Generated sample.txt.yaml.cards.txt
```

The file looks like this:

```
astuto|Un _____ zorro oyó el lejano canto de un gallo.|Un <font color="#ff0000">astuto</font> zorro oyó el lejano canto de un gallo.|zzTODO replace: <a href=https://www.bing.com/images/search?q=astuto&cc=es>pic_astuto</a> .|adj. Que tiene habilidad e ingenio para engañar / conseguir cualquier propósito. (sagaz, pícaro)|zzTODO replace: <a href=https://forvo.com/word/astuto/#es>sound_astuto</a> .

... etc.
```

### 5. Import the file, and click links in the browser

Import the file into Anki, and "Allow HTML in fields".  Set up your
Anki cards however you wish.

When all the cards are imported, you can view them in the Anki
browser.  If you have picture and/or sound fields, you can click on
the picture or sound links to open a web browser window and select
things to drop into the cards.

# Cloze deletions

Given a text file with some Spanish, e.g:

*sample.txt*

```
Un astuto zorro oyó de repente el lejano canto de un gallo.
```

You edit this text, adding asterisks around the text to cloze, with "hints" added after a pipe:

```
Un *astuto* zorro oyó *de repente|suddenly* el lejano canto de un gallo.
```

You then run `gen_cloze.rb` to generate a pipe-delimited ("|") file containing the
following fields:

* the clozed sentence
* an optional tag

## Steps to create the final file

### 1. Add asterisks

Add asterisks around phrases (here, _astuto_, _de repente_, and _gallo_):

```
Un *astuto* zorro oyó *de repente* el lejano canto de un *gallo*.
```

#### 1 b.  Optional: add sentence groups, cloze numbers, and hints.

See add '(#)' markers before things to group, '|' followed by a hint
for the cloze, and '[' and ']' around sentences that should remain
together in generated cards.

See `test/fixture/manual_test_gen_cloze.txt` for a sample file.  Try it out as follows:

```
ruby gen_cloze.rb ../test/fixture/manual_test_gen_cloze.txt -p something -t tagger -c
```


### 2. Run `gen_cloze.rb`


```
$ ruby gen_cloze.rb ../test/fixture/manual_test_gen_cloze.txt -p something -t tagger
Generated ../test/fixture/manual_test_gen_cloze.txt.cloze.txt
```


### 3. Import the file.

Import the file into Anki, and "Allow HTML in fields".  Set up your
Anki cards however you wish.


# Verb conjugations

Given a text file with some Spanish, e.g:

*sample.txt*

```
Un astuto zorro oyó de repente el lejano canto de un gallo.
```

You edit this text, adding asterisks around the verb, with a pipe and the root form of the verb:

```
Un astuto zorro *oyó|oir* de repente el lejano canto de un gallo.
```

You then run `gen_verbs.rb` to generate a pipe-delimited ("|") file containing the
following fields:

* the original sentence
* the sentence with a blank where you are to guess the conjugated form of the verb
* the form of the verb in the sentence (here, "oyó")
* the root of the verb ("oir")
* a link to www.conjugacion.es with the verb root, so you can copy the conj. table
* an optional tag


See `test/fixture/manual_test_gen_verbs.txt` for a sample file.  Try it out as follows:

```
ruby gen_verbs.rb ../test/fixture/manual_test_gen_verbs.txt -t sometage -c
```


Import the file into Anki, and "Allow HTML in fields".  Set up your
Anki cards however you wish.


# Listening comprehension

The "listening comp" cards use AWS's Polly service to generate mp3
files.  You'll need some gems (see Installation below), and an AWS dev
account, and creds stored in `~/.aws/credentials`.

## Installation

```
bundle install
```

Note: the aws-sdk gem pulls in a _ton_ of dependencies.  I'm not sure
how to limit that.  So start it running, and then go for a brisk walk
around the block ... because it installs 229 gems!

```
Bundle complete! 1 Gemfile dependency, 229 gems now installed.
```

Copy `config.yml.example` to `config.yml`, and fill in the voices you
want to use in `config.yml`.

## Usage

Create a text file with sentences that you want generated, e.g. in `texts/vocab.mp3`:

```
Conforme vayas haciendo amigos, te irás sintiendo mejor.
Según vamos detectando errores, los vamos corrigiendo.
No tienes por qué asustarte. No te hará daño.
```

Run the program to generate mp3 files using that text file (`-t` adds
"testing123" as a tag):

```
ruby gen_listening.rb texts/vocab.txt -t testing123
Generating es-ES mp3 files using speakers ["Conchita", "Lucia", "Enrique"]
Generated texts/vocab.txt.cards.txt
Generating sound files in /Users/jeff/Documents/Languages/Spanish/Tools/cards_from_text/audio
  ... /Users/jeff/Documents/Languages/Spanish/Tools/cards_from_text/audio/Conforme_vayas_hacie_1_wGYc2.mp3
  ... /Users/jeff/Documents/Languages/Spanish/Tools/cards_from_text/audio/No_tienes_por_qué_as_3_wGYc2.mp3
  ... /Users/jeff/Documents/Languages/Spanish/Tools/cards_from_text/audio/Según_vamos_detectan_2_wGYc2.mp3
Done

Audio files generated (suffixed with random token wGYc2).
Please close Anki, and move the files to ~/Library/Application Support/Anki2/User#/collection.media .
Open Anki and import the output file texts/vocab.txt.cards.txt to the appropriate deck (Fields: Text, Recording, Tag).
```

Follow the instructions for the generated files to the appropriate deck and card type.