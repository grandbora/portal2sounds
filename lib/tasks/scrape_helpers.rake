require 'mechanize'
require 'soundcloud'

namespace :scrape do
  @soundcloud_client = Soundcloud.new(:access_token => ENV['ACCESS_TOKEN'])

  desc "gets the users playlists"
  task playlists: :environment do
    @soundcloud_client.get('/me/playlists').each do |playlist|
      puts "#{playlist.title} #{playlist.uri}"
    end
  end

  desc "gets the users playlist"
  task playlist: :environment do
    playlist = @soundcloud_client.get(ENV['PLAYLIST_URI'])
    tracks = playlist.tracks.map { |track| {:id => track.id} }
    puts "#{tracks}"
  end

  desc "copy playlist"
  task copy_playlist: :environment do
    playlist = @soundcloud_client.get(ENV['PLAYLIST_URI'])
    tracks_ids = playlist.tracks.map { |track| {:id => track.id} }

    @soundcloud_client.put(ENV['PLAYLIST_URI2'], :playlist => {
      :tracks => tracks_ids
    })
  end

  desc "edit playlist"
  task edit_playlist: :environment do
    puts @soundcloud_client.put(ENV['PLAYLIST_URI'], :playlist => {
      :tag_list => "electronic, entertainment, portal2, portal2quotes, portal2sounds, \"Valve Games\""
    })
  end

  desc "delete playlist"
  task delete_playlist: :environment do
    @soundcloud_client.delete(ENV['PLAYLIST_URI2'])
  end

  desc "deletes the tracks in the playlist"
  task delete_tracks: :environment do
    playlist = @soundcloud_client.get(ENV['PLAYLIST_URI_TEST'])
    playlist.tracks.map do |track|
      puts @soundcloud_client.delete("/tracks/#{track.id}")
    end
  end

  desc "exchanges code to access token"
  task exchange_token: :environment do
    client = Soundcloud.new(:client_id => ENV['CLIENT_ID'],
                            :client_secret => ENV['CLIENT_SECRET'],
                            :redirect_uri => ENV['REDIRECT_URI'])
    puts client.exchange_token(:code => ENV['CODE'])
  end
end
