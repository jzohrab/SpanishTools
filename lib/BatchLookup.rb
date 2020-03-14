# Given a paragraph with delimited words,
# extracts data like the following:
# [
#   {
#     :word => "the word",
#     :context => "the full text containing the word",
#     :root => "the root (uninflected) form of the word",
#     :definitions => [
#       { :definition => "def 1", :example => "ex 1" },
#       ...
#       ]
#   }
# ]

require_relative './TextParser'

class BatchLookup

  ########################
  public

  def initialize()
    @console_log = true
  end
  
  def batch_lookup(para, lkp_src, settings = {})
    fullstop = settings[:fullstop] || "."

    tp = TextParser.new()
    data = tp.extract(para)

    # Do lookups
    words = data.map { |e| e[:words] }.flatten
    dict = get_dictionary(words, lkp_src)

    ret = []
    data.each do |d|
      ret << get_card_data_for_data(d, dict)
    end
    ret.flatten!
    ret.delete_if { |s| s.nil? }

    ret = add_index_to_words(ret)

    ret
  end

  attr_accessor :console_log

  ########################
  private

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
        while word_and_root = mutex.synchronize { word_queue.pop }
          word = word_and_root[:word]
          root = word_and_root[:root]

          definitions = lkp_src.lookup(root)
          mutex.synchronize do
            dict[word] = definitions
            puts "  ... #{word} (#{dict.keys.size} of #{all_words.count})" if @console_log
          end
        end
      end
    }.each(&:join)

    # puts "Done lookup of #{word_count} words in #{Time.now - start_time} s."
    dict
  end


  # Given a text, extracts array of data for one or more cards.
  # Note a single text may have multiple delimited words.
  def get_card_data_for_data(d, dict)
    output = d[:words].map do |w|
      word = w[:word]
      root = w[:root]

      lkp = dict[word]
      raise "missing dictionary entry for word #{w}" if lkp.nil?
      {
        :word => word,
        :text => d[:text],
        :root => lkp[:root],
        :definitions => lkp[:definitions].map { |de| de[:definition] }
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
