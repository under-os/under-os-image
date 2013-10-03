class EditorPage < UOS::Page

  def initialize(image)
    @original = image
    @cropped  = image.resize(UnderOs::Screen.size)
    @preview  = first('#preview')
    @preview.src = @cropped.raw
  end

end
