# Scan a paragraph for "chunks" (that is, one or more sentences that
# are delimited by '[' and ']'), and then extract the rest of the
# sentences.  See the tests for examples (in ../test).
class ParagraphExtractor

  def extract(p)
    # Regex determined by trial and error ...  The first part (before
    # the '|') finds a chunks, and the second finds anything terminated
    # by the paragraph return.
    #
    # For example,
    #
    #   "[This is. A chunk.]\nAnd a sentence."
    #
    # is returned as:
    #
    #   [ ["[This is. A chunk]", nil], [nil, "And a sentence."] ]

    # Hacks:
    # - "\n" added to end of paragraph to ensure last line of para
    #   matches the second part of regex.
    # - [ and ] replaced with additional paras to ensure that chunks
    #   are separated from the rest of text.
    parts = "#{p}\n".gsub('[', "\n[").gsub(']', "]\n").scan(/\s*(\[.*?\])|(.*?[\n])/m).
            flatten.
            delete_if { |s| s.nil? }

    ret = parts.
          map { |s| s.gsub('[', '').gsub(']', '') }.
          map { |s| s.strip }.
          delete_if { |s| s == "\n" }.
          delete_if { |s| s == '' }

    if ret.count == 0 then
      ret = [p]
    end

    return ret

  end

end
