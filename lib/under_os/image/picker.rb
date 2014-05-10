#
# A little module to wrap up the built-in
# iOS images picking/taking
#
class UnderOs::Image::Picker
  def initialize(options={})
    @animated   = options.delete(:animated) || true
    @_          = NoStatusBarPickerController.alloc.init
    @_.delegate = self
    @_.view.backgroundColor = UnderOs::App.history.current_page.view._.backgroundColor
  end

  def take(&block)
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
      @_.setSourceType(UIImagePickerControllerSourceTypeCamera)
      start(&block)
    else
      pick(&block)
    end
  end

  def pick(&block)
    @preview && @preview.remove
    @_.setSourceType(UIImagePickerControllerSourceTypePhotoLibrary)
    start(&block)
  end

  def start(&block)
    @block = block
    @page  = UnderOs::App.history.current_page._
    @page.presentViewController @_, animated: @animated, completion: nil
  end

  def imagePickerController(picker, didFinishPickingMediaWithInfo:info)
    image = UnderOs::Image.new(info[UIImagePickerControllerOriginalImage])

    if @_.sourceType == UIImagePickerControllerSourceTypePhotoLibrary
      preview image, picker.view
    else
      finish image # image from camera
    end
  end

  def finish(image)
    @page.dismissModalViewControllerAnimated(@animated)
    @block.call(image)
  end

  def preview(image, main_page)
    @preview ||= UnderOs::UI::View.new.tap do |view|
      view.size = UnderOs::Screen.size
      view.style.background = UnderOs::App.history.current_page.view.style.background

      @preview_image = UnderOs::UI::Image.new.tap do |preview_image|
        preview_image.insertTo(view)
        preview_image.style = {width: 320, height: 426, top: 70, left: 0}
      end

      UnderOs::UI::Label.new(text: "Preview").tap do |title|
        title.insertTo view
        title.style = {width: '100%', height: 50, textAlign: :center}
      end

      UnderOs::UI::Button.new(text: "Use").tap do |button|
        button.insertTo view
        button.on(:tap) { finish(image) }
        button.style = {right: 20, bottom: 10}
      end

      UnderOs::UI::Button.new(text: "Cancel").tap do |button|
        button.insertTo view
        button.on(:tap) { @preview.remove }
        button.style = {left: 20, bottom: 10}
      end
    end

    @preview_image.src = image
    main_page.addSubview @preview._
  end

  class NoStatusBarPickerController < UIImagePickerController
    def prefersStatusBarHidden
      true
    end

    def childViewControllerForStatusBarHidden
      nil
    end
  end
end
