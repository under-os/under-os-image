class EditorPage < UOS::Page

  def initialize(image)
    @original = image
    @cropped  = image.resize(UnderOs::Screen.size)
    @preview  = first('#preview')
    @preview.src = @cropped

    find('#buttons icon').each do |icon|
      icon.on(:tap){|e| start_editing(e.target)}
    end

    @menu     = first('#slider-menu')

    @menu.first('#okay').on(:tap)     { apply  }
    @menu.first('#cancel').on(:tap)   { cancel }
    @menu.first('slider').on(:change) {|e| update(e.target.value)}
  end

  def apply
    hide_menu
  end

  def cancel
    @preview.src = @cropped.raw
    hide_menu
  end

  def update(value)
    @value = value
    @preview.src = @cropped.filter(@edit_param.to_sym => value)
  end

  def start_editing(icon)
    @edit_param = icon.id
    @menu.first('slider').value = 0.5
    show_menu
  end

  def show_menu
    @menu.animate({bottom: 0})
  end

  def hide_menu
    @menu.animate({bottom: -@menu.size.y})
  end
end
