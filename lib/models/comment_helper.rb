require 'taglib'

class CommentHelper

  def comments(file_path, text)

    default_comment_list = [{
      :body => text,
      :timestamp => 10
    }]
    
    duration = TagLib::FileRef.open(file_path) do |fileref|
      fileref.audio_properties.length
    end

    return default_comment_list if duration < 3

    sentences = text.split(/((?<=[a-z0-9)][.?!])|(?<=[a-z0-9][.?!]"))\s+(?="?[A-Z])/)
    sentences.keep_if { |sentence| sentence.empty? == false }
    comment_gap = duration * 1000 / sentences.size

    sentences.each_with_index.map do |sentence, i|
      {
        :body => sentence,
        :timestamp => (comment_gap * i) + 30
      }
    end
  end
end
