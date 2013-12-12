require 'taglib'

class CommentHelper

  def comments(file_path, text)
    return TagLib::FileRef.open(file_path)
    TagLib::FileRef.open("wake_up.flac") do |fileref|
      unless fileref.null?
        tag = fileref.tag
        tag.title   #=> "Wake Up"
        tag.artist  #=> "Arcade Fire"
        tag.album   #=> "Funeral"
        tag.year    #=> 2004
        tag.track   #=> 7
        tag.genre   #=> "Indie Rock"
        tag.comment #=> nil

        properties = fileref.audio_properties
        properties.length  #=> 335 (song length in seconds)
      end
    end

    # {
    #     :body => comment[:text],
    #     :timestamp => comment[:timestamp
    #   }
    
  end
  
end
