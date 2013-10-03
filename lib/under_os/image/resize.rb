#
# creates a new image that fits the given size
#
class UnderOs::Image
  def resize(size)
    size      = UOS::Point.new(size)
    ratio     = size.x * 2 / @raw.size.width
    new_size  = CGSizeMake(size.x * 2, @raw.size.height * ratio)

    UIGraphicsBeginImageContext(new_size)
    @raw.drawInRect(CGRectMake(0,0,new_size.width,new_size.height))
    new_image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    self.class.new(new_image)
  end
end
