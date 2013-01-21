TEMPLATE_PATH = 'templates'
ALBUM_PATH = 'albums'
SCRIPT_PATH = 'scripts'
SITE_PATH = 'galleries'
THUMB_PATH = 'thumbs'
THUMB_NAME_FORMAT = 'thumb_%s'
WATERMARK_NAME = "water-ChristophediPascale02.png"

ALBUMS = %w( sacem-handicap-2012 )

desc "Build all images and web pages."
task :default => [:images, :themes]
task :images => :prepareGraphics

def hamlr( template, output, dSpace=nil )
  sh "ruby #{SCRIPT_PATH}/hamlr.rb #{template} #{dSpace} -o #{output}"
end

#####################################################
# Synthesize file tasks for album pages
ALBUMS.each {
  |theme|

  page = "#{SITE_PATH}/#{theme}.htm"
  task :themes => page
  file page => ["#{TEMPLATE_PATH}/theme.haml", "#{ALBUM_PATH}/#{theme}/#{theme}.yml"] do
    |t|
    hamlr( "#{TEMPLATE_PATH}/theme.haml", t.name, "#{ALBUM_PATH}/#{theme}/#{theme}.yml" )
  end
}

#####################################################
# Generate low-defs
#srcImages = FileList["#{ALBUM_PATH}/la-route-du-pain/*.tif"]  # For baguettebank
srcImages = FileList["#{ALBUM_PATH}/**/*.png", "#{ALBUM_PATH}/**/*.PNG", "#{ALBUM_PATH}/**/*.jpg", "#{ALBUM_PATH}/**/*.jpe", "#{ALBUM_PATH}/**/*.JPG", "#{ALBUM_PATH}/**/*.JPEG", "#{ALBUM_PATH}/**/*.jpeg", "#{ALBUM_PATH}/**/*.tif", "#{ALBUM_PATH}/**/*.TIF", "#{ALBUM_PATH}/**/*.tiff"]
srcImages.each do
  |src|

  lowDefDir = "#{SITE_PATH}/#{src.pathmap "%d"}"
  hiDefDir = "#{SITE_PATH}/#{src.pathmap "%d"}/hd"
  directory lowDefDir
  directory hiDefDir

  thumbDir = "#{SITE_PATH}/#{src.pathmap "%d"}/#{THUMB_PATH}"
  directory thumbDir
  
  lowDefName = "#{SITE_PATH}/#{src.ext "jpg"}"
  thumbName = "#{thumbDir}/#{THUMB_NAME_FORMAT % src.pathmap("%n")}.jpg"
  hiDefName = "#{hiDefDir}/#{src.pathmap "%n"}.jpg"

  task :images => [hiDefName, lowDefName, thumbName]

  file lowDefName => [src, lowDefDir] do
    |t|
    puts "Building #{t.name} from #{t.prerequisites[0]}"
    curPhoto = Image.read( t.prerequisites[0] ).first
    GC.start
    lowRes = curPhoto.resize_to_fit( 2048, LOW_RES_HEIGHT )
    lowRes = lowRes.blend( TILED_WATERMARK, 0.8, 1, SouthEastGravity )
    lowRes.write t.name
  end

  file hiDefName => [src, hiDefDir] do
    |t|
    puts "Building HD #{t.name} from #{t.prerequisites[0]}"
    curPhoto = Image.read( t.prerequisites[0] ).first
    GC.start
    hiRes = curPhoto.resize_to_fit( 2048, HI_RES_HEIGHT )
    hiRes = hiRes.blend( TILED_WATERMARK, 1.0, 1, SouthEastGravity )
    hiRes = hiRes.blend( TILED_WATERMARK, 1.0, 1, SouthWestGravity )
    hiRes.write t.name
  end

   file thumbName => [src, thumbDir] do
     |t|
    puts "Building thumb #{t.name} from #{t.prerequisites[0]}"
    curPhoto = Image.read( t.prerequisites[0] ).first
    GC.start
    thumb = curPhoto.resize_to_fit( 2048, THUMBNAIL_HEIGHT )
    thumb = thumb.add_profile('/etc/ImageMagick/sRGB.icm')
    thumb.write t.name { self.quality = 66; self.interlace = LineInterlace }
   end
  
end

task :prepareGraphics do

  require 'RMagick'
  include Magick

  LOW_RES_WIDTH = 1024
  LOW_RES_HEIGHT = 640
  HI_RES_HEIGHT = 1500
  THUMBNAIL_HEIGHT = 160 # dipascale.fr
  # For full tiling, adjust the dimensions to the cover the largest image
  TILED_WATERMARK = Image.new( 256, 256, TextureFill.new(Image.read(WATERMARK_NAME).first) )

end
