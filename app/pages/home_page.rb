class HomePage < UOS::Page
  def initialize
    first('#camera').on :tap do
      UOS::Image.take{|image| edit image}
    end

    first('#album').on :tap do
      UOS::Image.pick{|image| edit image}
    end
  end

  def edit(image)
    navigation.push EditorPage.new(image)
  end
end
