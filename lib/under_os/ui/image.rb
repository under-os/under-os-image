class UnderOs::UI::Image
  alias :src_before_image= :src=

  def src=(value)
    value = value._ if value.is_a?(UnderOs::Image)
    self.src_before_image = value
  end
end
