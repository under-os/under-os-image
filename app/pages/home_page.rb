class HomePage < UOS::Page
  def initialize
    @image_picker = UOS::ImagePicker.new(self)

    first('#camera').on :tap do
      @image_picker.capture do |image|
        p image
      end
    end

    first('#album').on :tap do
      @image_picker.select do |image|
        p image
      end
    end
  end
end
