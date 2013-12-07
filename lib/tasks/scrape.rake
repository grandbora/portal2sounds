require 'mechanize'
require 'soundcloud'

namespace :scrape do
  desc "portal2sounds"
  task portal2sounds: :environment do
    1.upto(27) do |i|
      scrape_page(i)
    end

  end

  desc "gets the users playlists"
  task playlists: :environment do
    client = Soundcloud.new(:access_token => ENV['ACCESS_TOKEN'])
    client.get('/me/playlists').each do |playlist|
      puts "#{playlist.title} #{playlist.uri}"
    end
  end

  desc "gets the users playlist"
  task playlist: :environment do
    client = Soundcloud.new(:access_token => ENV['ACCESS_TOKEN'])
    playlist = client.get(ENV['PLAYLIST_URI'])
    tracks = playlist.tracks.map { |track| {:id => track.id} }
    puts "#{tracks}"
  end

  desc "deletes the tracks in the playlist"
  task delete_tracks: :environment do
    client = Soundcloud.new(:access_token => ENV['ACCESS_TOKEN'])
    playlist = client.get(ENV['PLAYLIST_URI'])
    playlist.tracks.map do |track|
      puts client.delete("/tracks/#{track.id}")
    end
  end

  private
  def scrape_page(page_id)

    puts "\n STARTING PAGE #{page_id} \n"

    client = Soundcloud.new(:access_token => ENV['ACCESS_TOKEN'])
    home_page_mech = Mechanize.new

    home_page_mech.get("http://www.portal2sounds.com/index.php?p=#{page_id}") do |page|

      puts "\n #{page.title} \n "

      page.search("li.sound_list_item").each do |li|
        id = li.get_attribute("onclick").split("'")[1]
        title = li.search("a b").first.content
        narrator = li.search(".whospan b").first.content
        original_direct_link = "http://www.portal2sounds.com/sound.php?id=#{id}"
        original_perma_link = "http://www.portal2sounds.com/#{id}"
        file_name = title[0..25].downcase.gsub(/[^0-9a-z ]/i, '').gsub(' ', '-')
        file_path = "public/downloads/#{file_name}-#{id}.mp3"
        purchase_url = "http://store.steampowered.com/app/620/"
        purchase_title = "Buy PORTAL 2 on steam"

        puts "downloading file #{file_path} from #{original_direct_link}"

        direct_page_mech = Mechanize.new
        direct_page_mech.pluggable_parser.default = Mechanize::Download
        direct_page_mech.get(original_direct_link).save(file_path)

        puts "file #{file_path} saved"

        track = client.post('/tracks', :track => {
          :title => title,
          :asset_data => File.new(file_path, 'rb'),
          :description => "by <a href='#{narrator_url(narrator)}'>#{narrator}</a>(#{narrator_url(narrator)}) \n hear at #{original_perma_link}",
          :genre => 'entertainment',
          :tag_list => "portal2sounds, portal2, #{narrator}",
          :downloadable => true,
          :artwork_data => artwork_data(narrator),
          :purchase_url => purchase_url,
          :purchase_title => purchase_title
        })

        puts "file #{file_path} uploaded, permalink_url #{track.permalink_url}"

        playlist = client.get(ENV['PLAYLIST_URI'])
        tracks_ids = playlist.tracks.map { |track| {:id => track.id} }
        tracks_ids.push({:id => track.id})

        client.put(ENV['PLAYLIST_URI'], :playlist => {
          :tracks => tracks_ids
        })

        puts "track #{title} added to playlist"

        client.post("/tracks/#{track.id}/comments", :comment => {
          :body => title,
          :timestamp => 10
        })

        puts "comment #{title} added"

        puts "\n END OF TRACK #{id} \n"
      end
    end
  end

  def artwork_data(narrator)
    artwork_file = ([
      'caroline',
      'cave johnson',
      'core 1',
      'core 2',
      'defective turret',
      'glados',
      'turret',
      'wheatley'
    ].include? narrator.downcase) ? "#{narrator}.jpg" : "portal2.png"

    File.new("public/artworks/#{artwork_file}", 'rb')
  end

  def narrator_url(narrator)

    case narrator.downcase
      when 'announcer'        then "http://theportalwiki.com/wiki/Announcer"
      when 'caroline'         then "http://theportalwiki.com/wiki/Caroline"
      when 'cave johnson'     then "http://en.wikipedia.org/wiki/Cave_Johnson_(Portal)"
      when 'core 1'           then "http://theportalwiki.com/wiki/Cores"
      when 'core 2'           then "http://theportalwiki.com/wiki/Cores"
      when 'defective turret' then "http://theportalwiki.com/wiki/Defective_Turret"
      when 'glados'           then "http://en.wikipedia.org/wiki/GLaDOS"
      when 'turret'           then "http://theportalwiki.com/wiki/Turrets"
      when 'wheatley'         then "http://en.wikipedia.org/wiki/Wheatley_(Portal)"
      else ""
    end
  end
end
