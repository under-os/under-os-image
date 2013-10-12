class UnderOs::Image
  class Filter

    def initialize(params)
      self.params = params
    end

    def apply_to(image)
      image = image.raw if image.is_a?(UnderOs::Image)
      image = CIImage.alloc.initWithImage(image)
      image = apply_filters_to(image)

      UnderOs::Image.new(render(image))
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

    def highlights=(value) # 1.0 +/- 1.0
      add_filter :CIHighlightShadowAdjust, inputHighlightAmount: value
    end

    def midtone=(value) # 1.0 +/- 0.5
      add_filter :CIGammaAdjust, inputPower: value
    end

    def shadows=(value) # 1.0 +/- 1.0
      add_filter :CIHighlightShadowAdjust, inputShadowAmount: value
    end

    def sharpen=(value) # 1.0 +/- 1.0
      add_filter :CISharpenLuminance, inputSharpness: value
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

    def noise_reduce=(value)
      add_filter :CIMedianFilter
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

  protected

    def apply_filters_to(image)
      @filters.each do |name, filter|
        if filter.is_a?(Proc)
          image = instance_exec image, &filter
        else
          filter.setValue(image, forKey: 'inputImage')
          image = filter.outputImage
        end
      end

      image
    end

    def render(image)
      @context ||= begin # shared EAGL context
        gl_context = EAGLContext.alloc.initWithAPI(KEAGLRenderingAPIOpenGLES2)
        options    = {KCIContextWorkingColorSpace => nil}
        CIContext.contextWithEAGLContext(gl_context, options:options)
      end

      cg_image  = @context.createCGImage(image, fromRect:image.extent)
      new_image = UIImage.imageWithCGImage(cg_image)
      CGImageRelease(cg_image)

      new_image
    end

  private

    def add_filter(name, values={})
      @filters[name] ||= CIFilter.filterWithName(name.to_s)

      values.each do |key, value|
        @filters[name].setValue(value, forKey: key.to_s)
      end
    end
  end
end
