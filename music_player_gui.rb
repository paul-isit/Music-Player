require 'rubygems'
require 'gosu'

#initializing constants
TOP_COLOR = Gosu::Color.new(0xff_18200E)
BOTTOM_COLOR = Gosu::Color.argb(0xff_1D2710)
PLAYBAR_COLOR = Gosu::Color.argb(0xff_12180D)
TRACK_AREA_COLOR = Gosu::Color.argb(0xff_0A0E06)
HEADING_FONT_SIZE = 70
HEADING_COLOR = Gosu::Color.argb(0xff_D8D3D2)
TEXT_FONT_SIZE = 30
TEXT_COLOR = Gosu::Color.argb(0xff_FFFFFF)
TRACK_FONT_SIZE = 20
TRACK_COLOR = Gosu::Color.argb(0xff_FFFFFF)
ALBUM_CONTAINER_COLOR = Gosu::Color.argb(0xff_131413)

module ZOrder
  BACKGROUND, PLAYER, UI, TOP, TOP_TOP, ABOVE_TOP_TOP, MORE_TOP = *0..6
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

# Class for displaying the album covers
class ArtWork
	attr_reader :bmp, :cmp

	def initialize (big, small)
		@bmp = Gosu::Image.new(big)
        @cmp = Gosu::Image.new(small)
	end
end

# Class consisting of album details
class Album
	attr_accessor :title, :artist, :year, :genre, :tracks, :artwork
	def initialize (title, artist, year, genre, tracks, artwork)
		@title = title
		@artist = artist
		@year = year
		@genre = genre
		@tracks = tracks
		@artwork = artwork
	end
end

# Class consisting of track details
class Track
	attr_accessor :name, :location, :liked

	def initialize (name, location)
		@name = name
		@location = location
        @liked = false
	end
end

class MusicPlayerMain < Gosu::Window

    TrackLeftX = 50 #left side margin co-ordinates

    def initialize
        super 1300, 900
        self.caption = "Music Player"

        #initializing global variables
        @selected_album = nil   #for selected albums
        @selected_track = nil   #for selected track
        # @previously_selected_album = nil    #for previously selected album
        @selected_liked_song = nil  #for selected liked song
        @play_button_pressed = false    #for if or not the play button was pressed
        @liked_songs_button_pressed = false #for if or not the liked songs button was pressed
        @liked_songs = []   #arrary storing the liked songs
        #assigning global variables for the playbar buttons
        @playbar_buttons = Gosu::Image.new("playbarbuttons.png")
        @play_button = Gosu::Image.new("playbarbuttons/play.png")
        @pause_button = Gosu::Image.new("playbarbuttons/pause.png")
        @previous_button = Gosu::Image.new("playbarbuttons/previous.png")
        @next_button = Gosu::Image.new("playbarbuttons/next.png")
        @loop_button = Gosu::Image.new("playbarbuttons/loop.png")
        @like_button = Gosu::Image.new("playbarbuttons/like.png")
        @liked_button = Gosu::Image.new("playbarbuttons/liked.png")
        #assigning header font variables
        @header_font = Gosu::Font.new(HEADING_FONT_SIZE)
        @track_font = Gosu::Font.new(TRACK_FONT_SIZE)
        @text_font = Gosu::Font.new(TEXT_FONT_SIZE)


        @page = 0   #the current page number will be zero
        music_file = File.new("albums.txt", "r")
        @albums = read_all_albums(music_file)
        music_file.close()

        @albums_per_page = 6    #ive decided to draw 6 albums per page
        @current_page = 0
        @total_pages = (@albums.length / @albums_per_page.to_f).ceil
    end

    def read_track(music_file)
		name = music_file.gets().chomp
		location = music_file.gets().chomp
		track = Track.new(name, location)
		return track
	end

# Returns an array of tracks read from the given file

	def read_tracks(music_file)
		
		count = music_file.gets().to_i()
		tracks = Array.new()
		while count > 0
			track = read_track(music_file)
			tracks << track
			count -= 1
		end
		return tracks
	end

	def read_all_albums(music_file)
		count = music_file.gets().to_i()
		albums = Array.new()
		while count > 0
			album = read_album(music_file)
			albums << album
			count -= 1
		end
		return albums
	end

	def read_album(music_file)
		album_artist = music_file.gets().chomp
		album_title = music_file.gets().chomp
		ablum_year = music_file.gets().to_s().chomp
		album_genre = music_file.gets().to_i()
		tracks = read_tracks(music_file)
		album_cover = music_file.gets().chomp
        album_cover_small = music_file.gets().chomp
		album = Album.new(album_title, album_artist, ablum_year, album_genre, tracks, ArtWork.new(album_cover, album_cover_small))
		return album
	end

    ############# Function called for drawing the album covers ##############
    def draw_albums(albums)
        # it first considers which page we are on and hence which and how many ablums are supposed to be drawn
        start_index = @current_page * @albums_per_page  #calculates the start index according to the current page
        end_index = start_index + @albums_per_page - 1  #calculates the end index according to the current page
        visible_albums = albums[start_index..end_index] #array of visible albums according to the current page

        visible_albums.each_slice(3).with_index do |row, row_index|     #each_slice(3) divides the visible_albums array into three albums each row
            row.each_with_index do |album, column_index|    #each_with_index do works the same as a while loop but is more efficient
                @a = 480 + column_index * 273   #x co-ordinate for the album container
                @b = 100 + row_index * 340  #y co-ordinate for the album container
                Gosu.draw_rect(@a, @b, 263, 330, ALBUM_CONTAINER_COLOR, ZOrder::UI)     #draws the album container
                x = @a + 4
                y = @b + 4
                album.artwork.bmp.draw(x, y, ZOrder::UI)    #draws the album cover with respective to the album container co-ordiantes
                text_x = @a + 4
                text_y = @b + 260
                @text_font.draw_text(album.title, text_x, text_y, ZOrder::UI, 1.0, 1.0, TEXT_COLOR) #draws the album name in the container
                year_text_x = @a + 4
                year_text_y = @b + 290
                @text_font.draw_text(album.year, year_text_x, year_text_y, ZOrder::UI, 1.0, 1.0, TEXT_COLOR)    #draws the artist name in the container
            end
        end
    end

    #fucntion returns a boolean value for the condition described below according to the mouse value and is only called in button_down because we want it to check if something was "clicked"
    def area_clicked(leftX, topY, rightX, bottomY)  
        mouse_x >= leftX && mouse_x <= rightX && mouse_y >= topY && mouse_y <= bottomY
    end
    
    def display_track(title, ypos)
        @text_font.draw_text(title, TrackLeftX, ypos, ZOrder::ABOVE_TOP_TOP, 1.0, 1.0, TEXT_COLOR)
    end

    #plays the selected track given in the argument and sets the song playing flag to true
    def playTrack(track, albums)
            if track >= 0 and track < albums.tracks.length
                @song = Gosu::Song.new(albums.tracks[track].location)
                @song.play(false)
                @song_playing = true # Set song state to playing
            end
    end

    #function which when called pauses the track if it was being played and vice-versa. Basically acts like a play/pause button
    def play_pause_track
        if @song.playing? 
            @song.pause
            @song_playing = false
        elsif @song
            @song.play
            @song_playing = true
        end
    end

    #plays the next track, called by the next button
    def play_next_track
        if @selected_track
            current_index = @current_album.tracks.index(@selected_track)
            next_index = current_index + 1
            if next_index >= @current_album.tracks.length
            next_index = 0
            end
            @selected_track = @current_album.tracks[next_index]
            playTrack(next_index, @current_album)
            @play_button_pressed = false
        end
    end

    #plays the previous track, called by the previous button
    def play_previous_track
        if @selected_track
            current_index = @current_album.tracks.index(@selected_track)
            next_index = current_index - 1
            if next_index < 0
                next_index = @current_album.tracks.length - 1
            end
            @selected_track = @current_album.tracks[next_index]
            playTrack(next_index, @current_album)
        end
    end

   def draw_background
        draw_quad(0, 0, TOP_COLOR, 1300, 0, TOP_COLOR, 0, 900, BOTTOM_COLOR, 1300, 900, BOTTOM_COLOR, ZOrder::BACKGROUND)
   end

   def draw_heading
        @header_font.draw_text("PETRICHOR", 470, 15, ZOrder::TOP_TOP, 1.0, 1.0, HEADING_COLOR)
   end

   def draw_playbar
        draw_quad(0, 770, PLAYBAR_COLOR, 1300, 770, PLAYBAR_COLOR, 1300, 900, PLAYBAR_COLOR, 0, 900, PLAYBAR_COLOR, ZOrder::TOP_TOP)
        #if the song playing flag is set then draws the pause button if not then draws the play button
        if @song_playing
            @pause_button.draw(610, 800, ZOrder::TOP_TOP)
        else
            @play_button.draw(610, 800, ZOrder::TOP_TOP)
        end
        @previous_button.draw(535, 807, ZOrder::TOP_TOP)
        @next_button.draw(700, 807, ZOrder::TOP_TOP)
   end

   def draw_tracks_area
        draw_quad(0, 100, TRACK_AREA_COLOR, 470, 100, TRACK_AREA_COLOR, 470, 900, TRACK_AREA_COLOR, 0, 900, TRACK_AREA_COLOR, ZOrder::TOP)
        @text_font.draw_text("Liked Songs", 50, 105, ZOrder::ABOVE_TOP_TOP, 1.0, 1.0, TEXT_COLOR)
        @text_font.draw_text("Album Tracks", 230, 105, ZOrder::ABOVE_TOP_TOP, 1.0, 1.0, TEXT_COLOR)
        @text_font.draw_text("/", 214, 105, ZOrder::TOP_TOP, 1.0, 1.0, TEXT_COLOR)
   end

    def draw
        draw_albums(@albums)

        #acts like a hover for the liked songs and album tracks buttons
        mouse_over = mouse_over_button(mouse_x, mouse_y)
        if mouse_over
            Gosu.draw_rect(@x, @y, @l, 40, Gosu::Color::GRAY, ZOrder::TOP_TOP)  
        end

        #displays the track information of the selected album
        if @selected_album && @album_tracks_button_pressed
            @selected_album.tracks.each_with_index do |track, index|
                ypos = 145 + index * 30
                display_track(track.name, ypos)
            end

            Gosu.draw_rect(225, 100, 171, 40, Gosu::Color::GRAY, ZOrder::TOP_TOP)
        end

        #draws the track info on the playbar when a track is selected
        if @selected_track
            if @selected_album.tracks.include?(@selected_track)     #include? basically checks that is the selected track is included in the tracks informaition of the selected album
                @selected_album.artwork.cmp.draw(5, 775, ZOrder::ABOVE_TOP_TOP)     #only then it draws its track info in the playbar
                @track_font.draw_text(@selected_album.artist, 130, 845, ZOrder::ABOVE_TOP_TOP, 1.0, 1.0, Gosu::Color::WHITE)
            else
                @current_album.artwork.cmp.draw(5, 775, ZOrder::ABOVE_TOP_TOP)  #other wise it just draws the info of the current album 
                @track_font.draw_text(@current_album.artist, 130, 845, ZOrder::ABOVE_TOP_TOP, 1.0, 1.0, Gosu::Color::WHITE)
            end
            @text_font.draw_text(@selected_track.name, 130, 805, ZOrder::ABOVE_TOP_TOP, 1.0, 1.0, Gosu::Color::WHITE)
            x = 140 + @text_font.text_width(@selected_track.name)
            y = 790
            #if the selected track is liked or not, then draws the respective button image
            if @selected_track.liked
                @liked_button.draw(x, y, ZOrder::MORE_TOP)
            else
                @like_button.draw(x, y, ZOrder::ABOVE_TOP_TOP)
            end
        end

        #if the liked songs button was pressed
        if @liked_songs_button_pressed
            @liked_songs.each_with_index do |song, index|
                ypos = 145 + index * 30
                display_track(song.name, ypos)
            end

            Gosu.draw_rect(45, 100, 154, 40, Gosu::Color::GRAY, ZOrder::TOP_TOP)
        end
        draw_background
        draw_heading
        draw_playbar
        draw_tracks_area
    end

    #checks if a track has stopped playing, i.e., if it has finished, then moves onto the next track in the album
    def update
        if @selected_track && !@play_button_pressed
            if @song.playing? 
                @song_playing = true
            else
                play_next_track
            end
        end
    end


    def mouse_over_button(mouse_x, mouse_y)
        if ((mouse_x > 50 and mouse_x < 248) and (mouse_y > 105 and mouse_y < 135)) #for the "Liked Songs" button
            @x = 45
            @y = 100
            @l = 154
            return true
        elsif ((mouse_x > 230 and mouse_x < 395) and (mouse_y > 105 and mouse_y < 135)) #for the "Album Tracks" button
            @x = 225 
            @y = 100
            @l = 171
            return true
        else
            false
        end
    end

   
      

    def needs_cursor?; true; end

	def button_down(id)

        case id
        when Gosu::KB_LEFT, Gosu::KB_A
            # Scroll to previous page
            @current_page = (@current_page - 1) % @total_pages
            if @page == 1
                @page = 0
            else
                @page = 1
            end

        when Gosu::KB_RIGHT, Gosu::KB_D
            # Scroll to next page
            @current_page = (@current_page + 1) % @total_pages
            if @page == 1
                @page = 0
            else
                @page = 1
            end
        when Gosu::KB_SPACE #for the play/pause button
            play_pause_track
            @play_button_pressed = !@play_button_pressed
        when Gosu::MS_LEFT  
            #for the mouse left click on the play/pause button
            play_pause_x = 610
            play_pause_y = 800
            if area_clicked(play_pause_x, play_pause_y, play_pause_x + @play_button.width, play_pause_y + @play_button.height)
                play_pause_track
                @play_button_pressed = !@play_button_pressed
                return
            end
            #for the mouse left click on the next button
            next_button_x = 700
            next_button_y = 807
            if area_clicked(next_button_x, next_button_y, next_button_x + @next_button.width, next_button_y + @next_button.height)
                play_next_track
                return
            end
            #for the mouse left click on the previous button
            previous_button_x = 535
            previous_button_y = 807
            if area_clicked(previous_button_x, previous_button_y, previous_button_x + @previous_button.width, previous_button_y + @previous_button.height)
                play_previous_track
                return
            end
            #for the liked songs button display
            liked_songs_button_x = 50
            liked_songs_button_y = 105
            if area_clicked(liked_songs_button_x, liked_songs_button_y, 248, 135)
                @liked_songs_button_pressed = true
                @album_tracks_button_pressed = false
            end
            #for the album tracks button display
            album_tracks_button_x = 230
            album_tracks_button_y = 105
            if area_clicked(album_tracks_button_x, album_tracks_button_y, 395, 135)
                @liked_songs_button_pressed = false
                @album_tracks_button_pressed = true
            end
        end
           
            
            if id == Gosu::MS_LEFT

                if @selected_track
                    #co-ordinates of the like button
                    x = @text_font.text_width(@selected_track.name) + 140
                    y = 790
                    puts("selected tracks is working")
                    if area_clicked(x, y, x + @like_button.width, y + @like_button.height)
                        @selected_track.liked = !@selected_track.liked
                        puts("liked button pressed")
                        if @liked_songs.include?(@selected_track)
                            @liked_songs.delete(@selected_track)
                        else
                            @liked_songs << @selected_track
                        end
                    end
                end

                if @selected_album.nil?
                  # Check if an album was clicked
                  total_albums = @albums.length
                  albums_on_current_page = [@albums_per_page, total_albums - @page * @albums_per_page].min
                  albums_on_previous_pages = total_albums - albums_on_current_page
            
                  albums_on_current_page.times do |index|
                    album_index = @page * @albums_per_page + index
                    a = 480 + (index % 3) * 273
                    b = 100 + (index / 3) * 340
              
                    if area_clicked(a, b, a + @albums[album_index].artwork.bmp.width, b + @albums[album_index].artwork.bmp.height)
                        @selected_album = @albums[album_index]
                        @album_tracks_button_pressed = true
                      break
                    end
                  end
                else
                  # Check if a track was clicked
                  @selected_album.tracks.each_with_index do |track, index|
                    leftX = TrackLeftX
                    topY = 145 + index * 30
                    rightX = leftX + @text_font.text_width(track.name)
                    bottomY = topY + @text_font.height
              
                    if area_clicked(leftX, topY, rightX, bottomY)
                      @selected_track = track
                      puts("Now Playing #{track.name}")
                      playTrack(index, @selected_album)
                      @current_album = @selected_album
                      break
                    end
                  end
              
                  # Check if another album was clicked
                  total_albums = @albums.length
                  albums_on_current_page = [@albums_per_page, total_albums - @page * @albums_per_page].min
                  albums_on_previous_pages = total_albums - albums_on_current_page
              
                  albums_on_current_page.times do |index|
                    album_index = @page * @albums_per_page + index
                    a = 480 + (index % 3) * 273
                    b = 100 + (index / 3) * 340
              
                    if area_clicked(a, b, a + @albums[album_index].artwork.bmp.width, b + @albums[album_index].artwork.bmp.height)
                        @selected_album = @albums[album_index]
                        @album_tracks_button_pressed = true
                        @liked_songs_button_pressed = false
                      break
                    end
                  end
                end
            end
              

    end

end

MusicPlayerMain.new.show if __FILE__ == $0