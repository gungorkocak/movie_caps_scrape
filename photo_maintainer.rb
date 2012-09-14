require "rubygems"
require "csv"
require "fileutils"
require "digest/sha1"

class PhotoMaintainer
  
  def initialize
  
    @source       = "data"
    @destination  = "photos"
    @movie_db     = "#{@source}/movies.csv"
    @movie_table  = fetch_movie_directories
    @photo_db     = "photos.csv"

    ensure_destination_exists

  end

  def ensure_destination_exists
    unless File::directory? @destination
      puts "creating directory #{@destination}"
      Dir.mkdir @destination
    end
  end

  def fetch_movie_directories
    CSV.read @movie_db, encoding: "ISO8859-1"
  end

  def migrate_em_all

    @movie_table.each do |movie|   
      migrate_photos_from( { name: movie[0], directory: movie[1] } ) 
    end

  end

  def migrate_photos_from( movie )

    Dir.glob "#{movie[:directory]}/*.jpg" do |photo|

      hashed_photo_name = Digest::SHA1.hexdigest "#{movie[:directory]} $amet #{photo}"
      # source_photo      = "#{movie[:directory]}/#{photo}"
      source_photo      = photo
      destination       = "#{@destination}/#{hashed_photo_name}.jpg"

      FileUtils.cp source_photo, destination
      insert_enrty_of( { movie: movie[:name], name: destination } )
            
    end  

  end

  def insert_enrty_of( photo )
    CSV.open( @photo_db, "a+", encoding: "ISO8859-1") do |csv|
      puts "Writing to photos.csv: #{photo[:movie]}, #{photo[:name]}"
      csv << [ photo[:movie], photo[:name] ]
    end
  end

  def print_movie_table
    @movie_table.each { |movie| puts "Mapping #{movie[0]} -> #{movie[1]}"}
    return nil
  end
  
  
end