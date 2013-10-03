class EditorPage < UOS::Page

  def initialize(image)
    @image = first('#preview')
    @image.src = image.raw
  end

end
