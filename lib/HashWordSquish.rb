# coding: utf-8
class HashWordSquish

  def HashWordSquish.verb_object_endings(inf_termination)
    return ['', 'lo', 'los', 'la', 'las'].map { |e| "#{inf_termination}#{e}" }
  end
  
  # In Spanish words can be roughly grouped by their root forms, after
  # endings having been removed.
  PLURALS = ['s']
  ADJECTIVES = ['o', 'os', 'a', 'as']
  VERB_ENDING_OBJECTS = ['', 'lo', 'los', 'la', 'las']
  REGULAR_AR_VERB_ENDINGS = %w(a
aba
abais
aban
abas
ad
ado
amos
an
ando
ar
ara
arais
aran
aras
are
areis
aremos
aren
ares
aron
ará
arán
arás
aré
aréis
aría
aríais
aríamos
arían
arías
as
ase
aseis
asen
ases
aste
asteis
e
emos
en
es
o
ábamos
áis
áramos
áremos
ásemos
é
éis
ó) + HashWordSquish.verb_object_endings('ar')

  REGULAR_ER_VERB_ENDINGS = %w(a
amos
an
as
e
ed
emos
en
er
eremos
erá
erán
erás
eré
eréis
ería
eríais
eríamos
erían
erías
es
ido
iera
ierais
ieran
ieras
iere
iereis
ieren
ieres
ieron
iese
ieseis
iesen
ieses
imos
iste
isteis
iéramos
iéremos
iésemos
ió
o
puesto
áis
éis
í
ía
íais
íamos
ían
ías
) + HashWordSquish.verb_object_endings('er')

  REGULAR_IR_VERB_ENDINGS = %w(a
amos
an
as
e
en
es
id
ido
iera
ierais
ieran
ieras
iere
iereis
ieren
ieres
ieron
iese
ieseis
iesen
ieses
imos
ir
iremos
irá
irán
irás
iré
iréis
iría
iríais
iríamos
irían
irías
iste
isteis
iéramos
iéremos
iésemos
ió
o
áis
í
ía
íais
íamos
ían
ías
ís) + HashWordSquish.verb_object_endings('ir')

  def are_like_after_stripping_endings(a, b, endings)
    re = /(#{endings.join('|')})$/
    return a =~ re && b =~ re && a.gsub(re, '') == b.gsub(re, '')
  end
  
  def are_like(a, b)
    # Quick exit
    return false if a.nil? || b.nil?
    return false if a[0] != b[0]
    return true if a == b

    [
      PLURALS,
      ADJECTIVES,
      VERB_ENDING_OBJECTS,
      REGULAR_AR_VERB_ENDINGS,
      REGULAR_ER_VERB_ENDINGS,
      REGULAR_IR_VERB_ENDINGS
    ].each do |endings|
      return true if are_like_after_stripping_endings(a, b, endings)
    end

    return false
  end
  
  def group_like_words(word_list, ostream = nil)

    words = word_list.uniq.sort

    # Cheap optimization: do an aggressive chop of word endings from
    # each word to find its shortest possible root, and use this as
    # the first pass of comparison when iterating through all words to
    # find groups.  This will not be accurate as a basis of
    # comparison, but it will serve as an initial rough cut.
    shortest_possible_word_roots = {}
    all_endings =
      [
        PLURALS,
        ADJECTIVES,
        VERB_ENDING_OBJECTS,
        REGULAR_AR_VERB_ENDINGS,
        REGULAR_ER_VERB_ENDINGS,
        REGULAR_IR_VERB_ENDINGS
      ].
        flatten.
        uniq.
        sort { |a, b| a.length != b.length ? a.length <=> b.length : a <=> b }.
        reverse
    # puts all_endings
    re = /(#{all_endings.join('|')})$/
    words.each do |w|
      shortest_possible_word_roots[w] = w.gsub(re, '')
    end
    
    ret = []

    # Pop top word from the sorted list, add to a new list C.  For
    # each word remaining in the sorted list, if it's like the top
    # word, add to C.
    current = words.shift
    while !current.nil?
      current_short_root = shortest_possible_word_roots[current]

      # puts "Building list for current word #{current}"
      likes = [current]
      words.each_with_index do |w, i|
        if shortest_possible_word_roots[w] == current_short_root && are_like(current, w) then
          likes << w
          words[i] = nil  # Don't change the size of the array during iteration
        end
      end

      ret << likes.sort
      words.compact!

      if ret.size % 1000 == 0 && !ostream.nil? then
        ostream.puts " ... #{ret.size} groups, #{words.size} words remaining"
      end

      current = words.shift
    end

    if !ostream.nil? then
      ostream.puts " ... #{ret.size} groups, #{words.size} words remaining"
    end

    ret
  end
  
  def squish(word_frequency_hash, ostream = nil)
    words = word_frequency_hash.keys.sort
    groups = group_like_words(words, ostream)
    groups.map do |g|
      {
        word: g[0],
        count: g.inject(0) { |sum, e| sum + word_frequency_hash[e] },
        forms: g
      }
    end
  end

end
