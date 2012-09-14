require "rubygems"
require "mechanize"
require "cgi"
require "csv"
require 'digest/sha1'
require "image_downloader"


class PhotoFetcher

  def initialize
    @main_url   = "http://www.cinemasquid.com"
    @agent      = Mechanize.new
  end

  
  def movie_list

    index_page  = @agent.get "#{@main_url}/blu-ray/movies/screenshots"
    movie_nodes = index_page.search('ul.icon-list li a') # movie = { text: "sth", href: "link" }
    
    @movie_list = []
    
    movie_nodes.each do |node|
      @movie_list << { title: node.text, link: "#{@main_url}#{node['href']}" }
    end

    puts "#{@movie_list.length} Movies Found."

    return @movie_list

  end

  def download_photos_from_movies
    movie_list.each do |movie|
      puts "Now downloading #{movie[:title]}..."
      download_photos_of movie
    end
  end

  def download_photos_of( movie = {} )
    
    movie_link  = movie[:link] # in case of movie = { .. link: "link" } || "link"
    movie_dir   = "data/" + Digest::SHA1.hexdigest( "#{movie[:title]}}" )


    unless File::directory? movie_dir
      puts "creating directory #{movie_dir}"
      Dir.mkdir movie_dir
    end

    downloader    = ImageDownloader::Process.new movie_link, movie_dir
    downloader.parse( regexp: /[^'"]+screenshot-med-[^'"]+\.jpg/i )

    downloader.download

    movie[:path]  = "#{movie_dir}"
    insert_movie_folder_map_of movie

  end


  def print_movie_list
    
    @movie_list.each do |movie|   
      puts "#{movie[:title]} -> #{movie[:link]}"   
    end

    return nil

  end

  
  private

  def insert_movie_folder_map_of( movie = {} )
    
    CSV.open("data/movies.csv", "a+", encoding: "ISO8859-1") do |csv|
      puts "Writing to csv: #{movie[:title]}, #{movie[:path]}"
      csv << [ movie[:title], movie[:path] ]
    end

  end
  
end

