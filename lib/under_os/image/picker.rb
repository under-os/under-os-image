#
# A little module to wrap up the built-in
# iOS images picking/taking
#
class UnderOs::Image::Picker
  def initialize(options={})
    @animated   = options.delete(:animated) || true
    @_          = UIImagePickerController.alloc.init
    @_.delegate = self
  end

  def capture(&block)
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
      @_.setSourceType(UIImagePickerControllerSourceTypeCamera)
      start(&block)
    else
      select(&block)
    end
  end

  def select(&block)
    @_.setSourceType(UIImagePickerControllerSourceTypePhotoLibrary)
    start(&block)
  end

  def start(&block)
    @block = block
    @page  = UnderOs::Application.current_page._
    @page.presentModalViewController @_, animated: @animated
  end

  def imagePickerController(picker, didFinishPickingImage:image, editingInfo:info)
    @page.dismissModalViewControllerAnimated(@animated)
    @block.call(image)
  end
end
