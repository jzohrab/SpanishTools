# coding: utf-8
module LanguageUtils

  def LanguageUtils.verb_object_endings(inf_termination)
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
ó) + LanguageUtils.verb_object_endings('ar')

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
) + LanguageUtils.verb_object_endings('er')

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
ís) + LanguageUtils.verb_object_endings('ir')

  def LanguageUtils.are_like_after_stripping_endings(a, b, endings)
    re = /(#{endings.join('|')})$/
    return a =~ re && b =~ re && a.gsub(re, '') == b.gsub(re, '')
  end
  
  def LanguageUtils.are_like(a, b)
    # Quick exit
    return false if a.nil? || b.nil?
    adown = a.downcase
    bdown = b.downcase
    return false if adown[0] != bdown[0]
    return true if adown == bdown

    [
      PLURALS,
      ADJECTIVES,
      VERB_ENDING_OBJECTS,
      REGULAR_AR_VERB_ENDINGS,
      REGULAR_ER_VERB_ENDINGS,
      REGULAR_IR_VERB_ENDINGS
    ].each do |endings|
      return true if are_like_after_stripping_endings(adown, bdown, endings)
    end

    return false
  end

end
