require 'mechanize'
require 'soundcloud'

namespace :scrape do
  @soundcloud_client = Soundcloud.new(:access_token => ENV['ACCESS_TOKEN'])
  @most_popular_500 = []

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
      :default_tags => "portal2, portal2quotes, portal2sounds, \"Valve Games\", electronic",
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

  desc "updates existing quotes"
  task :update_tracks_metadata, [:offset] do |t, args|

    limit = 200
    offset = args.offset.to_i

    while offset < 3000 do
      puts "updating batch #{offset} - #{offset + limit} \n "

      update_batch(limit, offset)
      offset += limit

      puts "tracks until #{offset} are updated \n "
    end
  end

  private
  def update_batch(limit, offset)
    tracks = @soundcloud_client.get('/me/tracks', :limit => limit, :offset => offset)
    whitelist = []

    tracks.each do |track|
      whitelist.push(track) if (track[:tag_list].include?("portal2") && track[:tag_list].include?("portal2sounds"))
    end

    whitelist.each_with_index do |track, i|
      begin
        puts " \n track number #{offset} + #{i} \n "
        update_track(track)
      rescue => e
        puts "===========EXCEPTION RECEIVED=========== \n #{e} \n #{e.message} \n #{e.inspect} \n #{e.backtrace}"
      end
    end
  end
  def update_track(track)
    metadata = @metadata[:portal2]
    original_perma_link = track[:description].match(/.*hear at (http:\/\/www.portal2sounds.com\/\d+)$/)[1]
    narrator = track[:description][/<a.*>.*<\/a>/].match(/>(.*)</)[1]
    narrator_url, narrator_artwork = narrator_metada(narrator, metadata)

    description = "by <a href='#{narrator_url}'>#{narrator}</a> \n this content is provided by #{metadata[:base_url][0..-2]} \n hear at #{original_perma_link}"
    tag_list = "#{metadata[:default_tags]} , \" #{narrator} \" "

    puts " \n found track #{track[:permalink_url]}  \n "
    puts "existing description #{track[:description]}"
    puts "new description #{description}"
    puts "===="
    puts "existing tag_list #{track[:tag_list]}"
    puts "new tag_list #{tag_list}"

    @soundcloud_client.put(track[:uri], :track => {
      :description => description,
      :tag_list => tag_list
    })

    puts "track #{track[:permalink_url]} is updated"
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
