require 'mechanize'
require 'soundcloud'

namespace :scrape do

  @soundcloud_client = Soundcloud.new(:access_token => ENV['ACCESS_TOKEN'])
  portal2_characters = {
    :announcer => {
      :url => "http://theportalwiki.com/wiki/Announcer"
    },
    :caroline => {
      :url => "http://theportalwiki.com/wiki/Caroline"
    },
    :cave_johnson => {
      :url => "http://en.wikipedia.org/wiki/Cave_Johnson_(Portal)"
    },
    :cave_prime => {
      :url => "http://en.wikipedia.org/wiki/Cave_Johnson_(Portal)"
    },
    :alternate_cave => {
      :url => "http://en.wikipedia.org/wiki/Cave_Johnson_(Portal)"
    },
    :core_1 => {
      :url => "http://theportalwiki.com/wiki/Cores"
    },
    :core_2 => {
      :url => "http://theportalwiki.com/wiki/Cores"
    },
    :defective_turret => {
      :url => "http://theportalwiki.com/wiki/Defective_Turret"
    },
    :glados => {
      :url => "http://en.wikipedia.org/wiki/GLaDOS"
    },
    :turret => {
      :url => "http://theportalwiki.com/wiki/Turrets"
    },
    :wheatley => {
      :url => "http://en.wikipedia.org/wiki/Wheatley_(Portal)"
    }
  }.with_indifferent_access

#
#
#
# TODO FILL METADATA
#
#
#

  @metadata ={
    :portal2 => {
      :dir_name => "portal2",
      :playlist_uri => ENV["PLAYLIST_URI"],
      :base_url => "http://www.portal2sounds.com/",
      :purchase_url => "http://store.steampowered.com/app/620/",
      :purchase_title => "Buy PORTAL 2 on steam",
      :default_artwork => "portal2.png",
      :default_tags => "portal2, portal2sounds, portal2quotes, \"Valve Games\"",
      :characters => portal2_characters
    },
    :portal2dlc => {
      :dir_name => "portal2dlc",
      :playlist_uri => ENV["PLAYLIST_URI"],
      :base_url => "http://dlc.portal2sounds.com/",
      :purchase_url => "http://store.steampowered.com/app/620/",
      :purchase_title => "Buy PORTAL 2 on steam",
      :default_artwork => "portal2.png",
      :default_tags => "portal2, portal2sounds, portal2quotes",
      :characters => portal2_characters
    },
    :portal2pti => {
      :dir_name => "portal2pti",
      :playlist_uri => ENV["PLAYLIST_URI"],
      :base_url => "http://dlc2.portal2sounds.com/",
      :purchase_url => "http://store.steampowered.com/app/620/",
      :purchase_title => "Buy PORTAL 2 on steam",
      :default_artwork => "portal2.png",
      :default_tags => "portal2, portal2sounds, portal2quotes",
      :characters => portal2_characters
    }
  }

  desc "scrape web_site"
  task :web_site, [:web_site, :page_count] do |t, args|
    metadata = @metadata.with_indifferent_access[args.web_site]
    scrape_web_site(args.page_count.to_i, metadata)
  end

  private
  def scrape_web_site(page_count, metadata)
    1.upto(page_count) do |i|
      scrape_page(i, metadata)
    end
  end

  def scrape_page(page_id, metadata)

    puts "\n STARTING PAGE #{page_id} \n"

    home_page_mech = Mechanize.new
    home_page_mech.get("#{metadata[:base_url]}index.php?p=#{page_id}") do |page|

      puts "\n #{page.title} \n "

      page.search("li.sound_list_item").each_with_index do |li, i|
        begin
          scrape_track(li, i, page_id, metadata)
        rescue => e
          puts "===========EXCEPTION RECEIVED=========== \n #{e} \n #{e.message} \n #{e.inspect} \n #{e.backtrace}"
        end
      end
    end
  end

  def scrape_track(li, i, page_id, metadata)
    id = li.get_attribute("onclick").split("'")[1]
    text = li.search("a b").first.content
    narrator = li.search(".whospan b").first.content
    narrator_url, narrator_artwork = narrator_metada(narrator, metadata)
    track_title = "#{narrator}: #{text}"
    original_direct_link = "#{metadata[:base_url]}sound.php?id=#{id}&stream"
    original_perma_link = "#{metadata[:base_url]}#{id}"
    file_name_part = text[0..25].downcase.gsub(/[^0-9a-z ]/i, '').gsub(' ', '-')
    file_path = "public/downloads/#{file_name_part}-#{id}.mp3"

    puts "\n Track #{page_id} - #{i} \n "

    puts "downloading file #{file_path} from #{original_direct_link}"

    direct_page_mech = Mechanize.new
    direct_page_mech.pluggable_parser.default = Mechanize::Download
    direct_page_mech.get(original_direct_link).save(file_path)

    puts "file #{file_path} saved"

    track = @soundcloud_client.post('/tracks', :track => {
      :title => track_title,
      :asset_data => File.new(file_path, 'rb'),
      :description => "by <a href='#{narrator_url}'>#{narrator}</a>(#{narrator_url}) \n hear at #{original_perma_link}",
      :genre => 'entertainment',
      :tag_list => "#{metadata[:default_tags]} , \" #{narrator} \" ",
      :downloadable => true,
      :artwork_data => narrator_artwork,
      :purchase_url => metadata[:purchase_url],
      :purchase_title => metadata[:purchase_title]
    })

    puts "file #{file_path} uploaded, permalink_url #{track.permalink_url}"

    playlist = @soundcloud_client.get(metadata[:playlist_uri])
    tracks_ids = playlist.tracks.map { |track| {:id => track.id} }
    tracks_ids.push({:id => track.id})

    @soundcloud_client.put(metadata[:playlist_uri], :playlist => {
      :tracks => tracks_ids
    })

    puts "track #{track_title} added to playlist"

    @soundcloud_client.post("/tracks/#{track.id}/comments", :comment => {
      :body => text,
      :timestamp => 10
    })

    puts "comment #{text} added"

    puts "\n END OF TRACK #{id} \n"
  end

  def narrator_metada(narrator, metadata)

    normalized_narrator_name = narrator.downcase.gsub(' ', '_')
    artwork_file = (metadata[:characters].keys.include? normalized_narrator_name) ?
                    "#{normalized_narrator_name}.jpg" : metadata[:default_artwork]
    [
      metadata[:characters][normalized_narrator_name][:url],
      File.new("public/artworks/#{metadata[:dir_name]}/#{artwork_file}", 'rb')
    ]
  end
end
