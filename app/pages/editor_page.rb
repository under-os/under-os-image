class EditorPage < UOS::Page

  def initialize(image)
    @original = image
    @cropped  = image.resize(UnderOs::Screen.size)
    @preview  = first('#preview')
    @preview.src = @cropped.raw

    @menu     = first('#slider-menu')
    @menu.find('icon').each do |icon|
      icon.on(:tap) { hide_menu }
    end

    find('#buttons icon').each do |icon|
      icon.on(:tap){|e| start_editing(e.target)}
    end
  end

  def start_editing(icon)
    show_menu
    p icon.id
  end

  def show_menu
    @menu.animate({bottom: 0})
  end

  def hide_menu
    @menu.animate({bottom: -@menu.size.y})
  end

end
