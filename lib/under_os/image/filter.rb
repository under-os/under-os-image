class UnderOs::Image
  class Filter

    attr_reader :image

    def initialize(params={})
      self.params = params
    end

    def apply_to(image)
      self.image = image
      apply
    end

    def image=(image)
      @image = CIImage.alloc.initWithImage(
        image.is_a?(UnderOs::Image) ? image._ : image)
    end

    def apply
      UnderOs::Image.new(render)
    end

    def params
      @params ||= {}
    end

    def params=(params)
      @params  = {} # original param values
      @filters = {}

      params.each do |key, value|
        @params[key.to_sym]  = value
        self.__send__ "#{key}=", value
      end
    end

    def saturation=(value) # 1.0 +/- 0.25
      add_filter :CIColorControls, inputSaturation: value
    end

    def brightness=(value) # 0.0 +/- 0.25
      add_filter :CIColorControls, inputBrightness: value
    end

    def contrast=(value) # 1.0 +/- 0.25
      add_filter :CIColorControls, inputContrast: value
    end

    def exposure=(value) # 0.0 +/- 0.25
      add_filter :CIExposureAdjust, inputEV: value
    end

    def vibrance=(value) # 0.0 +/- 0.25
      add_filter :CIVibrance, inputAmount: value
    end

    def shadows=(value) # 0 +/- 1.0
      add_filter :CIToneCurve, inputPoint1: CIVector.vectorWithX(0.2, Y: 0.2 + (0.25 * value))
    end

    def midtone=(value) # 0 +/- 1.0
      add_filter :CIToneCurve, inputPoint2: CIVector.vectorWithX(0.5, Y: 0.5 + (0.25 * value))
    end

    def highlights=(value) # 0 +/- 1.0
      add_filter :CIToneCurve, inputPoint3: CIVector.vectorWithX(0.75, Y: 0.75 + (0.25 * value))
    end

    def sharpen=(value) # 0.5 +/- 0.5
      add_filter :CIUnsharpMask, inputRadius: 1.5, inputIntensity: value
    end

    def temperature=(value) # 6500 +/- 1500
      add_filter :CITemperatureAndTint, inputTargetNeutral: CIVector.vectorWithX(value, Y:0)
    end

    def tint=(value) # 0.0 +/- 50
      add_filter :CITemperatureAndTint, inputNeutral: CIVector.vectorWithX(6500, Y:-(value))
    end

    def sepia=(value)
      add_filter :CISepiaTone, inputIntensity: value
    end

    def vignette_radius=(value) # 1.0 +/- 0.5
      add_filter :CIVignette, inputRadius: value
    end

    def vignette_intensity=(value) # 1.0 +/- 1.0
      add_filter :CIVignette, inputIntensity: value
    end

    def pixellate_scale=(value)
      add_filter :CIPixellate, inputScale: value
    end

    def pixellate_center=(value)
      add_filter :CIPixellate, inputCenter: value
    end

    def mono_color=(value) # CIColor.colorWithRed(value, green:value, blue:value, alpha:1.0)
      add_filter :CIColorMonochrome, inputColor: value
    end

    def mono_intensity=(value)
      add_filter :CIColorMonochrome, inputIntensity: value
    end

    def posterize=(value)
      add_filter :CIColorPosterize, inputLevels: value
    end

    def scale=(value)
      add_filter :CILanczosScaleTransform, inputScale: value
    end

    def aspect_ratio=(value)
      add_filter :CILanczosScaleTransform, inputAspectRatio: value
    end

    def crop=(value)
      add_filter :CICrop, inputRectangle: value
    end

    def straighten=(value)
      add_filter :CIStraightenFilter, inputAngle: value
    end


    def method_missing(name, *args, &block)
      if respond_to?("#{name}=")
        @params[name.to_sym]
      else
        super
      end
    end

    def render(image=@image)
      image     = CIImage.alloc.initWithImage(image.is_a?(UnderOs::Image) ? image._ : image) if image != @image
      image     = apply_filters_to(image)
      cg_image  = UnderOs::Image::Filter.context.createCGImage(image, fromRect:image.extent)
      new_image = UIImage.imageWithCGImage(cg_image)
      CGImageRelease(cg_image)

      new_image
    end

    # shared EAGL context
    def self.context
      @context ||= begin
        gl_context = EAGLContext.alloc.initWithAPI(KEAGLRenderingAPIOpenGLES2)
        options    = {KCIContextWorkingColorSpace => nil}
        CIContext.contextWithEAGLContext(gl_context, options:options)
      end
    end

  protected

    def apply_filters_to(image)
      @filters.each do |name, filter|
        if filter.is_a?(Proc)
          image = instance_exec image, &filter
        else
          filter = self.class.filter_for(name, filter)
          filter.setValue(image, forKey: 'inputImage')
          image = filter.outputImage
          filter.setValue(nil, forKey: 'inputImage')
        end
      end

      image
    end

  private

    def add_filter(name, values={})
      @filters[name] ||= {}

      values.each do |key, value|
        @filters[name][key] = value
      end
    end

    def self.filter_for(name, params)
      @filters_cache ||= {}
      @filters_cache[name] ||= CIFilter.filterWithName(name.to_s)

      filter = @filters_cache[name]
      filter.setDefaults

      params.each do |key, value|
        filter.setValue(value, forKey: key.to_s)
      end

      filter
    end
  end
end
