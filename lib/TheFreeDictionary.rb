# coding: utf-8
# Wrapper around TheFreeDictionary website.

require 'cgi'
require 'uri'
require 'net/http'
require 'net/http/responses'

class TheFreeDictionary

  # Init.
  # content = content of a fake page for offline testing.
  def initialize(content = nil)
    @debug = false
    @content = content
  end

  attr_accessor :debug

  # Return struct for given word:
  # {
  #   :root => "the root form of the word (e.g., can search for a verb inflection)"
  #   :definitions => [
  #     {
  #       :definition => "the def",
  #       :example => "an example sentence for this def'n"
  #     },
  #     ...
  #   ]
  # }
  def lookup(s)
    body = get_page(s)
    root = body.scan(/\<h1\>.*?\<\/h1\>/).first
    root = CGI.unescapeHTML(strip_html_tags(root)) unless root.nil?

    definitions = body.scan(/\<div class="ds-single">.*?\<\/div\>/)
    definitions += body.scan(/\<div class="ds-list">.*?\<\/div\>/)
    definitions += body.scan(/\<div class="sds-list">.*?\<\/div\>/)
    # puts definitions.inspect

    # FreeDict returns some entries as <strong> entries.  E.g.,
    # searching for "perro" returns a number of different dog types,
    # sayings, etc.  Assuming for now that I'm only looking for
    # general entries.
    definitions.delete_if { |s| s =~ /\<strong\>/ }

    definitions.map! do |d|
      extract_definition_and_illustration(d)
    end

    return {
      :root => root,
      :definitions => definitions
    }
  end

  ##############
  private

  def print_debug(s)
    puts s.to_s if @debug
  end


  # Get the webpage for the current word, return full content as-is.
  def get_page(s)
    return @content if @content

    encoded_s = URI.encode_www_form_component(s)
    uri = "https://es.thefreedictionary.com/#{encoded_s}"
    uri = URI(uri)
    res = Net::HTTP.get_response(uri)
    res.body.force_encoding("UTF-8")
  end

  def strip_html_tags(s)
    return s if s.nil?
    return s.gsub(/\<.*?\>/, '').strip
  end
  
  def extract_definition_and_illustration(d_ex_struct)
    # puts '-' * 5
    # puts d_ex_struct
    ill_re = /\<span class="illustration"\>.*?\<\/span\>/
    definition = d_ex_struct.gsub(ill_re, '')
    definition.gsub!(/\<b\>\d+\<\/b\>./, '')
    definition.gsub!(/\<span class="Syn"\>(.*?)\<\/span\>/, "(\\1)")
    definition.gsub!(' )', ')')  # Hack to fix Syn span gsub.
    illustration = d_ex_struct.scan(ill_re).join('; ')
    # puts illustration

    return {
      :definition => strip_html_tags(definition).gsub(/^\d+\.\s*/, ''),
      :example => strip_html_tags(illustration)
    }
  end
  
end


# Command-line testing
if __FILE__ == $0
  puts "Command-line lookup"
  content = nil
  # content = File.read(File.join(File.dirname(__FILE__), '..', 'test', 'fixture', 'thefreedictionary_sample_Asomar.html'))
  # puts content

  f = TheFreeDictionary.new(content)
  f.debug = true
  w = ARGV[0]
  exit if w.nil?

  puts f.lookup(w)
end
