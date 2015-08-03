# This Ruby script generates two Keyhole Markup Language files:
#  1. points.kml	- a point for every photo with GPS coords
#  2. route.kml		- a single line that joins every photo with GPS coords
#
# from a folder (and sub-folders) of digital photos
#
# The intention is to create a chronological map of
#  photographed destinations from the digital photos themselves
#
# Usage: ruby photo-mapper.rb starting_directory
# e.g.:  ruby photo-mapper.rb Photos
#
# Author: Andrew Freemantle			http://www.fatlemon.co.uk/photo-mapper



require 'exifr'
require 'date'


# The Panasonic DMC-TZ40 always saves GPS coords. Even indoors. Exclude photos with these coords..
INVALID_GPS_COORDS = [17056881.853375, 17056881.666666668]
# Exclude the following directories when traversing..
IGNORE_DIR = ['.', '..', '.git', '.DS_Store', '@eaDir']
# List of supported photo filename extensions..
ALLOWED_EXTENSIONS = ['.jpg', '.JPG', '.jpeg', '.JPEG']


# Directory traversing class
#  initialized with a starting path, it recursively descends through
#  any directories it finds that aren't in the IGNORE_DIR array above
class Traverse

	def initialize(path, pointsFile, routeFile)
		puts "in " + path
		@files = Dir.entries(path).sort
		@files.each do |f|
			if !IGNORE_DIR.include? f
				if File.directory?(File.join(path, f))
					@t = Traverse.new(File.join(path, f), pointsFile, routeFile)
				elsif File.file?(File.join(path, f))

					# Is this an allowed file?
					if ALLOWED_EXTENSIONS.include? File.extname(f)
						# Does this file have Geo coords?
						puts "Got allowed file #{File.join(path,f)}"

						begin
							@file = EXIFR::JPEG.new(File.join(path, f))
							if @file.exif?()
								# We have EXIF, but do we have sensible Lat & Long?
								if @file.gps != nil
									if !INVALID_GPS_COORDS.include? @file.gps.latitude
										#puts @file.gps
										pointsFile.puts("<Placemark><name>#{f}</name><Point><coordinates>#{@file.gps.longitude},#{@file.gps.latitude},#{@file.gps.altitude}</coordinates></Point></Placemark>")
										routeFile.puts("#{@file.gps.longitude},#{@file.gps.latitude},0 ")
									else
										#puts "No GPS in " + ARGV[0]
									end
								end
							else
								#puts "No EXIF in " + ARGV[0]
							end
						rescue EOFError
							# End Of File can happen for partially copied or uploaded photos
							#  and there's nothing we can do here but report out and skip
							puts "Reached EOF for #{File.join(path,f)} - skipped."
						end
					end

				end
			end
		end

		pointsFile.flush()
		routeFile.flush()

	end
end


# Start the two output files:
pointsFile = File.open('points.kml', 'w')
routeFile = File.open('route.kml', 'w')

date = Date.today

# write the file headers
pointsFile.puts("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://www.opengis.net/kml/2.2\">
<Folder>
	<name>points</name>
	<description>Generated on #{date.strftime('%a %-d %b %Y')} by photo-mapper - http://www.fatlemon.co.uk/photo-mapper</description>
	<open>1</open>")

routeFile.puts("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://www.opengis.net/kml/2.2\">
<Folder>
  <name>route</name>
	<description>Generated on #{date.strftime('%a %-d %b %Y')} by photo-mapper - http://www.fatlemon.co.uk/photo-mapper</description>
  <open>1</open>
  <Style id=\"linestyle\">
    <LineStyle>
      <color>ff000000</color>
      <width>2</width>
    </LineStyle>
  </Style>
  <Placemark>
    <name>Route</name>
    <styleUrl>#linestyle</styleUrl>
    <LineString>
      <extrude>1</extrude>
      <tessellate>1</tessellate>
      <coordinates>")


go = Traverse.new(File.absolute_path(ARGV[0]), pointsFile, routeFile)


# Close the files
pointsFile.puts("
</Folder>
</kml>")
pointsFile.flush()

routeFile.puts("</coordinates>
    </LineString>
  </Placemark>
</Folder>
</kml>")
routeFile.flush()

# Done  :o)
