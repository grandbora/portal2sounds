class ScHelper

  @sc_client

  def initialize(access_token)
    @sc_client = Soundcloud.new(:access_token => access_token)
  end

  def delete_user_tracks(user_id)
    batch = user_tracks(user_id)
    while batch.size > 0
      puts "batch IIIIII"
      batch.each do |track|
        begin
          delete_track(track)
        rescue e
          puts "===========EXCEPTION RECEIVED=========== \n #{e} \n #{e.message} \n #{e.inspect} \n #{e.backtrace} \n \n #{track}"
        end
      end
      batch = user_tracks(user_id)
    end
  end

  def user_tracks(user_id)
    @sc_client.get("/users/#{user_id}/tracks")
  end

  def delete_track(track)
    puts "deleting /tracks/#{track.id}"
    @sc_client.delete("/tracks/#{track.id}")
  end


end
