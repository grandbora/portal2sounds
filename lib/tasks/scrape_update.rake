require 'mechanize'
require 'soundcloud'

namespace :scrape do
  @soundcloud_client = Soundcloud.new(:access_token => ENV['ACCESS_TOKEN'])

  desc "updates existing quotes"
  task update_tracks: :environment do

  end
end
