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

  def take(&block)
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
      @_.setSourceType(UIImagePickerControllerSourceTypeCamera)
      start(&block)
    else
      pick(&block)
    end
  end

  def pick(&block)
    @_.setSourceType(UIImagePickerControllerSourceTypePhotoLibrary)
    start(&block)
  end

  def start(&block)
    @block = block
    @page  = UnderOs::Application.current_page._
    @page.presentViewController @_, animated: @animated, completion: nil
  end

  def imagePickerController(picker, didFinishPickingImage:image, editingInfo:info)
    @page.dismissModalViewControllerAnimated(@animated)
    @block.call(UnderOs::Image.new(image))
  end
end
