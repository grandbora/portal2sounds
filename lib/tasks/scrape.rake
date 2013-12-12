require 'mechanize'
require 'soundcloud'
require 'models/metadata_container.rb'
require 'models/comment_helper.rb'

namespace :scrape do

  @soundcloud_client = Soundcloud.new(:access_token => ENV['ACCESS_TOKEN_GQ'])

  desc "scrape web_site"
  task :web_site, [:web_site, :page_count] do |t, args|
    metadata_container = MetadataContainer.new(args.web_site)
    scrape_web_site(args.page_count.to_i, metadata_container)
  end

  private
  def scrape_web_site(page_count, metadata_container)
    1.upto(page_count) do |i|
      scrape_page(i, metadata_container)
    end
  end

  def scrape_page(page_id, metadata_container)

    puts "\n STARTING PAGE #{page_id} \n"

    home_page_mech = Mechanize.new
    home_page_mech.get("#{metadata_container.base_url}index.php?p=#{page_id}") do |page|

      puts "\n #{page.title} \n "

      page.search("li.sound_list_item").each_with_index do |li, i|
        begin
          scrape_track(li, i, page_id, metadata_container)
          sleep(5)
        rescue => e
          puts "===========EXCEPTION RECEIVED=========== \n #{e} \n #{e.message} \n #{e.inspect} \n #{e.backtrace} \n \n #{li}"
        end
      end
    end
  end

  def scrape_track(li, i, page_id, metadata_container)
    id = li.get_attribute("onclick").split("'")[1]
    text = li.search("a b").first.content

    original_direct_link = "#{metadata_container.base_url}sound.php?id=#{id}&stream"
    original_perma_link = "#{metadata_container.base_url}#{id}"
    file_name_part = text[0..25].downcase.gsub(/[^0-9a-z ]/i, '').gsub(' ', '-')
    file_path = "public/downloads/#{file_name_part}-#{id}.mp3"

    narrator = metadata_container.narrator(li.search(".whospan b").first.content)
    track_title = "#{narrator[:title]}: #{text}"
    description = narrator[:url] ? "by <a href='#{narrator[:url]}'>#{narrator[:title]}</a>" : "by #{narrator[:title]}"
    description += " \n this content is provided by #{metadata_container.base_url[0..-2]} \n hear at #{original_perma_link}"
    description += " \n text : <i>#{text}</i>"

    puts "\n Track #{page_id} - #{i} \n downloading file #{file_path} from #{original_direct_link}"

    direct_page_mech = Mechanize.new
    direct_page_mech.pluggable_parser.default = Mechanize::Download
    direct_page_mech.get(original_direct_link, [], ENV["REFERER"]).save(file_path)

    puts "file #{file_path} saved"

    track = @soundcloud_client.post('/tracks', :track => {
      :title => track_title,
      :asset_data => File.new(file_path, 'rb'),
      :description => description,
      :genre => 'electronic',
      :tag_list => "#{metadata_container.default_tags} , #{narrator[:tags]}",
      :downloadable => true,
      :sharing => "public",
      :artwork_data => narrator[:artwork],
      :purchase_url => metadata_container.purchase_url,
      :purchase_title => metadata_container.purchase_title
    })

    puts "file #{file_path} uploaded, permalink_url #{track.permalink_url} id : #{track.id}"

    CommentHelper.new.comments(file_path, text).reverse.each do |comment|
      @soundcloud_client.post("/tracks/#{track.id}/comments", :comment => comment)
    end
    
    puts "comment #{text} added"
    puts "\n END OF TRACK #{id} \n"
  end
end
