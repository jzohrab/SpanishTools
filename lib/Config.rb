# Wrapper for config file, ensure format is valid.

require 'yaml'

class Config

  def initialize(config_file_path = File.join(__dir__, '..', 'config.yml'))
    @config = YAML.load_file(config_file_path)
  end

  def language_code()
    ret = @config[:polly][:language_code]
    raise 'missing key polly/language_code?' if ret.nil?
    ret
  end

  def speaker_ids()
    ret = @config[:polly][:speaker_ids]
    raise 'missing key polly/speaker_ids?' if ret.nil?
    ret
  end

  def random_speaker_id()
    s = speaker_ids()
    return s[rand(s.size)]
  end

  def output_dir()
    ret = @config[:polly][:output_dir]
    raise 'missing key polly/output_dir?' if ret.nil?
    ret
  end

end
