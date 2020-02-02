# Scan a paragraph for "chunks" (that is, one or more sentences that
# are delimited by '[' and ']'), and then extract the rest of the
# sentences.  See the tests for examples (in ../test).
class SentenceExtractor

  def extract_sentences(p, terminator = "\.")
    # Regex determined by trial and error ...  The first part (before
    # the '|') finds a chunks, and the second finds anything terminated
    # by the terminator.
    #
    # For example,
    #
    #   "[This is. A chunk.] And a sentence."
    #
    # is returned as:
    #
    #   [ ["[This is. A chunk]", nil], [nil, "And a sentence."] ]
    parts = p.scan(/\s*(\[.*?\])|(.*?[#{terminator}])/m).
            flatten.
            delete_if { |s| s.nil? }

    ret = parts.
          map { |s| s.gsub('[', '').gsub(']', '') }.
          map { |s| s.strip }.
          delete_if { |s| s == terminator }.
          delete_if { |s| s == '' }

    return ret

  end

end
