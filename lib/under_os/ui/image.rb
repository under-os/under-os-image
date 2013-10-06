class UnderOs::UI::Image
  alias :src_before_image= :src=

  def src=(value)
    value = value.raw if value.is_a?(UnderOs::Image)
    self.src_before_image = value
  end
end
