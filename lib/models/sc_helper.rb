class ScHelper
  
  @sc_client

  def initialize(access_token)
    @sc_client = Soundcloud.new(:access_token => access_token)
  end

  def delete_user_tracks
    @sc_client.get("/me/tracks").each do |track|
      delete_track(track)
    end
  end

  def delete_track(track)
    @sc_client.delete("/me/tracks/#{track.id}")
  end


end
