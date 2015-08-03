# photo-mapper
---

####`photo-mapper` is a simple script that generates [KML files](https://en.wikipedia.org/wiki/Keyhole_Markup_Language) that plot the location and route of your travels from the GPS coordinates in your digital photographs. These KML files can then be opened in [Google Earth](https://www.google.com/earth/) or uploaded to [Google Maps](https://maps.google.com).


This Ruby script generates two Keyhole Markup Language files:

1. `points.kml`	- a point for every photo with GPS coords
2. `route.kml`	- a single line that joins every photo with GPS coords


`points.kml` looks like this in Google Earth:  
![Google Earth overlaid with points generated from digital photo metadata](http://www.fatlemon.co.uk/public/images/2015/photo-mapper-google-earth-point-400px.jpg)

`routes.kml` looks like this in Google Maps:  
![Google maps overlaid with route generated from digital photo metadata](http://www.fatlemon.co.uk/public/images/2015/photo-mapper-google-map-route-400px.jpg)


## Getting Started
* You'll need the [Ruby language](https://www.ruby-lang.org) installed
* And the [Ruby exifr Library](https://rubygems.org/gems/exifr), which you can get by running `gem install exifr`


## Usage

Simply point the script at the folder containing your photo collection from the Terminal or Command Prompt and it will recursively search for all JPEG photos and read their GPS coordinates:


`ruby photo-mapper.rb {starting_directory}`

e.g.

`ruby photo-mapper.rb Photos`
