class MetadataContainer

  @metadata

  def initialize(web_site)
    @metadata = metadata(web_site)
  end

  def base_url
    @metadata[:base_url]
  end

  def default_tags
    @metadata[:default_tags]
  end

  def purchase_url
    @metadata[:purchase_url]
  end

  def purchase_title
    @metadata[:purchase_title]
  end

  def narrator(narrator_name)
    normalized_narrator_name = narrator_name.downcase.gsub(' ', '_')

    return {
      :artwork => File.new("public/artworks/#{@metadata[:dir_name]}/#{normalized_narrator_name}.jpg", 'rb'),
      :url => @metadata[:characters][normalized_narrator_name][:url],
      :tags => @metadata[:characters][normalized_narrator_name][:tags],
      :title => @metadata[:characters][normalized_narrator_name][:title]
    } if (@metadata[:characters].keys.include? normalized_narrator_name)

    {
      :artwork => File.new("public/artworks/#{@metadata[:dir_name]}/#{@metadata[:default_artwork]}", 'rb'),
      :url => false,
      :tags => "\"" + narrator_name + "\"",
      :title => narrator_name
    }
  end

  private
  def metadata(web_site)
    all_metadata = {
      :portal2 => {
        :dir_name => "portal2",
        :base_url => "http://www.portal2sounds.com/",
        :purchase_url => "http://store.steampowered.com/app/620/",
        :purchase_title => "Buy Portal 2 on steam",
        :default_artwork => "portal2.png",
        :default_tags => "\"Portal 2\", \"Portal 2 Quotes\", \"Valve Games\", Speech",
        :characters => characters
      },
      :portal2dlc => {
        :dir_name => "portal2",
        :base_url => "http://dlc.portal2sounds.com/",
        :purchase_url => "http://store.steampowered.com/app/620/",
        :purchase_title => "Buy Portal 2 on steam",
        :default_artwork => "portal2.png",
        :default_tags => "\"Portal 2 In Motion\", \"Portal 2\", \"Portal 2 Quotes\", \"Valve Games\", Speech",
        :characters => characters
      },
      :portal2pti => {
        :dir_name => "portal2",
        :base_url => "http://dlc2.portal2sounds.com/",
        :purchase_url => "http://store.steampowered.com/app/620/",
        :purchase_title => "Buy Portal 2 on steam",
        :default_artwork => "portal2.png",
        :default_tags => "\"Portal 2 Perpetual Testing Initiative\", \"Portal 2\", \"Portal 2 Quotes\", \"Valve Games\", Speech",
        :characters => characters
      },
      :portal1 => {
        :dir_name => "portal2",
        :base_url => "http://p1.portal2sounds.com/",
        :purchase_url => "http://store.steampowered.com/app/400/",
        :purchase_title => "Buy Portal on steam",
        :default_artwork => "portal.jpg",
        :default_tags => "\"Portal\", \"Portal 1\", \"Portal 1 Quotes\", \"Valve Games\", Speech",
        :characters => characters
      }
    }.with_indifferent_access

    all_metadata[web_site]
  end

  def characters
    {
      :announcer => {
        :url => "http://theportalwiki.com/wiki/Announcer",
        :tags => "Announcer",
        :title => "Announcer"
      },
      :caroline => {
        :url => "http://theportalwiki.com/wiki/Caroline",
        :tags => "Caroline",
        :title => "Caroline"
      },
      :cave_johnson => cave_johnson("Cave Prime"),
      :cave_prime => cave_johnson("Cave Prime"),
      :alternate_cave => cave_johnson("Dark Cave"),
      :core_1 => core("Core 1"),
      :core_2 => core("Core 2"),
      :core_3 => core("Core 3"),
      :core_4 => core("Core 4"),
      :curiosity_sphere => core("Curiosity Sphere"),
      :cake_sphere => core("Cake Sphere"),
      :aggressive_sphere => core("Aggressive Sphere"),
      :defective_turret => {
        :url => "http://theportalwiki.com/wiki/Defective_Turret",
        :tags => "\"Defective Turret\", Turret",
        :title => "Defective Turret"
      },
      :turret => {
        :url => "http://theportalwiki.com/wiki/Turrets",
        :tags => "Turret",
        :title => "Turret"
      },
      :glados => {
        :url => "http://en.wikipedia.org/wiki/GLaDOS",
        :tags => "GLaDOS",
        :title => "GLaDOS"
      },
      :wheatley => {
        :url => "http://en.wikipedia.org/wiki/Wheatley_(Portal)",
        :tags => "Wheatley",
        :title => "Wheatley"
      }
    }.with_indifferent_access
  end

  def core(extra_tag)
    {
      :url => "http://theportalwiki.com/wiki/Cores",
      :tags => "\"Portal Core\", \"#{extra_tag}\" ",
      :title => "Portal Core"
    }
  end

  def cave_johnson(extra_tag)
    {
      :url => "http://en.wikipedia.org/wiki/Cave_Johnson_(Portal)",
      :tags => "\"Cave Johnson\", \"#{extra_tag}\" ",
      :title => "Cave Johnson"
    }
  end


end
