class StampImage < ActiveRecord::Base
  attr_accessible :photo, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at
  
  belongs_to :user
  has_many :stamps, :dependent => :nullify
  
  has_attached_file :photo, :url  => "/assets/stamp_images/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/stamp_images/:id/:style/:basename.:extension"
  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 3.megabytes
  
  def generate_graphics
    STAMP_COLORS.each do |color|
      generate_graphic_for_color(color)
    end
    update_attribute(:generated_at, Time.zone.now)
  end
  
  def generate_graphic_for_color(color)
    source = Magick::Image.read(photo.path).first
    stamp_overlay = Magick::Image.read("#{Rails.root}/public/images/stamp_image_overlay.png").first
    source.resize_to_fill!(stamp_overlay.columns, stamp_overlay.rows)
    source = source.quantize(256, Magick::GRAYColorspace).contrast(true)
    source.composite!(stamp_overlay, Magick::CenterGravity, 0, 0, Magick::OverCompositeOp)
    colored = Magick::ImageList.new
    colored.new_image(70, 70) { self.background_color = color }
    source.matte = false
    colored.composite!(source.negate, Magick::CenterGravity, Magick::CopyOpacityCompositeOp)
    output_dir = File.dirname(photo.path(color))
    output = File.join(output_dir, (File.basename(photo.path(color), '.*') + '.png'))
    FileUtils.mkdir_p(output_dir) unless File.exist? output_dir
    File.delete(output) if File.exist? output
    colored.write(output)
  end
end
