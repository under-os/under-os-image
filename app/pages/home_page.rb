class HomePage < UOS::Page
  def initialize
    @image_picker = UOS::Image::Picker.new(self)

    first('#camera').on :tap do
      @image_picker.capture{|image| edit image}
    end

    first('#album').on :tap do
      @image_picker.select{|image| edit image}
    end
  end

  def edit(image)
    navigation.push EditorPage.new(image)
  end
end
