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

    return default_comment_list if duration < 2

    sentences = text.split(/((?<=[a-z0-9)][.?!])|(?<=[a-z0-9][.?!]"))\s+(?="?[A-Z])/ )
    sentences.keep_if { |sentence| sentence.empty? == false }

    max_comment_count = (duration / 2).ceil
    if sentences.size > max_comment_count
      slice_size = (sentences.size / max_comment_count).round
      sentences = sentences.each_slice(slice_size).map {|a| a.join(" ")}
    end    
    
    time_per_letter = duration * 1000 / text.size
    time_per_comment = duration * 1000 / sentences.size

    last_ts = 40
    result_list = []
    sentences.each do |sentence|
      result_list.push({
        :body => sentence,
        :timestamp => last_ts
      })
      last_ts += ((time_per_letter * sentence.size) + time_per_comment) / 2
    end
    result_list

    # last_ts = 40
    # comment_gap = duration * 1000 / sentences.size
    # sentences.each_with_index.map do |sentence, i|
    #   {
    #     :body => sentence,
    #     :timestamp => last_ts + comment_gap * i
    #   }
    # end
  end
end
