# Given a paragraph with delimited words,
# extracts data like the following:
# [
#   {
#     :word => "the word",
#     :context => "the full sentence containing the word",
#     :root => "the root (uninflected) form of the word",
#     :definitions => [
#       { :definition => "def 1", :example => "ex 1" },
#       ...
#       ]
#   }
# ]

require_relative './SentenceExtractor'
require_relative './WordExtractor'

class BatchLookup

  ########################
  public

  def batch_lookup(para, lkp_src, settings = {})
    fullstop = settings[:fullstop] || "."
    all_words = get_words(para)
    # puts all_words.inspect
    dict = get_dictionary(all_words, lkp_src)
    # puts dict.inspect

    sentences = extract_sentences(para)
    ret = []
    sentences.each do |s|
      ret << get_card_data_for_sentences(s, dict)
    end
    ret.flatten!
    ret.delete_if { |s| s.nil? }

    ret = add_index_to_words(ret)

    ret
  end


  ########################
  private
  
  def get_words(s)
    we = WordExtractor.new()
    words = we.extract_words(s)
    words
  end

  # Parallelized lookup
  #
  # per https://stackoverflow.com/questions/8778732/parallel-http-requests-in-ruby
  def get_dictionary(all_words, lkp_src)
    start_time = Time.now

    # Don't mutate the arg passed in.
    #
    # Reversing so that lookups are done in the order they're passed
    # in (this is not necessary at all, but I want the lookup order to
    # _approximately match the order of the words in the source file.)
    word_queue = all_words.dup.reverse

    thread_count = 20
    dict = {}
    mutex = Mutex.new

    thread_count.times.map {
      Thread.new(word_queue, dict) do |word_queue, dict|
        while word = mutex.synchronize { word_queue.pop }
          definitions = lkp_src.lookup(word)
          mutex.synchronize do
            dict[word] = definitions
            puts "  ... #{word} (#{dict.keys.size} of #{all_words.count})"
          end
        end
      end
    }.each(&:join)

    # puts "Done lookup of #{word_count} words in #{Time.now - start_time} s."
    dict
  end

  # Given a paragraph, extract the sentences.
  # Para given as text, separates at "\n" or at fullstop
  def extract_sentences(p, fullstop = ".")
    se = SentenceExtractor.new()
    return se.extract_sentences(p, fullstop)
  end

  # Given a sentence, extracts array of data for one or more cards.
  # Note a single sentence may have multiple delimited words.
  def get_card_data_for_sentences(s, dict)
    words = get_words(s)
    return nil if words.size == 0
    output = words.map do |w|
      d = dict[w]
      raise "missing dictionary entry for word #{w}" if d.nil?
      {
        :word => w,
        :sentence => s.gsub('*', '').strip,
        :root => d[:root],
        :definitions => d[:definitions].map { |de| de[:definition] }
      }
    end
    output
  end

  def add_index_to_words(words)
    index = 0
    total = words.count
    return words.map do |entry|
      index += 1
      entry[:index] = "#{index} of #{total}"
      entry
    end
  end

end


# Command-line testing
if __FILE__ == $0
  require_relative 'TheFreeDictionary'

  puts "Command-line batch lookup"
  w = ARGV[0]
  exit if w.nil?

  content = File.read(w)
  b = BatchLookup.new()
  ret = b.batch_lookup(content, TheFreeDictionary.new(), settings = {})
  puts ret.inspect

end
