require 'soundcloud'

namespace :update do
  # @soundcloud_client = Soundcloud.new(:access_token => ENV['ACCESS_TOKEN_GB'])
  @playlist = []

  desc "updates the given playlist content with the most popular quotes"
  task :playlist, [:offset, :limit] do |t, args|

    limit = args.limit.to_i
    offset = args.offset.to_i

    while offset < 3000 do
      puts "updating batch #{offset} - #{offset + limit} \n "

      playlist_update_batch(limit, offset)
      offset += limit

      puts "tracks until #{offset} are updated \n "
    end

    puts @playlist.inspect

    puts @soundcloud_client.put(ENV['PLAYLIST_URI_P2PETI'], :playlist => {
      :tracks => @playlist.first(50)
    })
  end

  private
  def playlist_update_batch(limit, offset)
    tracks = @soundcloud_client.get('/me/tracks', :limit => limit, :offset => offset, :order => 'created_at')
    whitelist = []

    tracks.each do |track|

      puts track[:tag_list]

      whitelist.push(track) if (track[:tag_list].include?("portal2") && track[:tag_list].include?("Portal 2 In Motion") == false && track[:tag_list].include?("portal2peti"))
    end

    whitelist.each_with_index do |track, i|
      begin
        puts " \n track number #{offset} + #{i} \n found track #{track[:permalink_url]} id: #{track[:id]} \n "
        insert_to_playlist(track)
      rescue => e
        puts "===========EXCEPTION RECEIVED=========== \n #{e} \n #{e.message} \n #{e.inspect} \n #{e.backtrace} \n \n #{track}"
      end
    end
  end

  def insert_to_playlist(track)
    track_score = track.playback_count.to_i + track.download_count.to_i + track.favoritings_count.to_i + track.comment_count.to_i  + track.likes_count.to_i + track.reposts_count.to_i
    puts "track_score: #{track_score} track #{track[:permalink]} id: #{track[:id]} \n "

    return @playlist.push({
      :id => track.id,
      :score => track_score
    }) if @playlist.empty?

    @playlist.each_with_index do |cur_item, i|
      next if cur_item[:score] > track_score
      @playlist.insert(i, {
        :id => track.id,
        :score => track_score
      })
      break
    end
  end
end
