class UnderOs::Image
  class Filter

    def initialize(params)
      self.params = params
    end

    def params
      @params
    end

    def params=(params)
      @params  = params
      @filters = build_filters_from(params)
    end

    def apply_to(image)
      image = image.raw if image.is_a?(UnderOs::Image)
      image = CIImage.alloc.initWithImage(image)

      @filters.each do |filter|
        filter.setValue(image, forKey: 'inputImage')
        image = filter.outputImage
      end

      cg_image  = UnderOs::Image::Filter.context.createCGImage(image, fromRect:image.extent)
      new_image = UIImage.imageWithCGImage(cg_image)
      CGImageRelease(cg_image)

      UnderOs::Image.new(new_image)
    end

    def self.context # shared EAGL context
      @context ||= begin
        gl_context = EAGLContext.alloc.initWithAPI(KEAGLRenderingAPIOpenGLES2)
        options    = {KCIContextWorkingColorSpace => nil}

        CIContext.contextWithEAGLContext(gl_context, options:options)
      end
    end

    def build_filters_from(params)
      filters = {}.tap do |filters|
        params.each do |key, value|
          next if value == nil
          filter = filter_for(key)
          filters[filter] ||= {}
          key, value = value_for(key, value)
          filters[filter][key] = value if key
        end
      end

      filters.each do |filter, params|
        filter.setDefaults

        params.each do |key, value|
          filter.setValue(value, forKey: key)
        end
      end

      filters.keys
    end

    def filter_for(param)
      raise "Can't find filter named #{param.inspect}" if ! FILTERS[param]
      filter_name = FILTERS[param][0]
      @filters_cache ||= {}

      if [:tint_color, :tint_intensity].include?(param)
        @filters_cache['tint_filter'] ||= CIFilter.filterWithName(filter_name)
      else
        @filters_cache[filter_name] ||= CIFilter.filterWithName(filter_name)
      end
    end

    def value_for(key, value)
      value = case key
      when :contrast           then value + 0.5
      when :brightness         then value - 0.5
      when :saturation         then value * 2
      when :exposure           then value - 0.5
      when :vibrance           then value - 0.5
      when :highlights         then value + 0.5
      when :shadows            then value + 0.5
      when :vignette_intensity then value + 2
      when :vignette_radius    then value + 1
      when :tint_color         then UnderOs::Color.new(value * Math::PI).ci
      when :mono_color         then CIColor.colorWithRed(value, green:value, blue:value, alpha:1.0)
      end

      value ? [FILTERS[key][1], value] : []
    end

    FILTERS = {
      saturation:         %w[ CIColorControls         inputSaturation           ], # 1.0
      brightness:         %w[ CIColorControls         inputBrightness           ], # 1.0
      contrast:           %w[ CIColorControls         inputContrast             ], # 1.0
      exposure:           %w[ CIExposureAdjust        inputEV                   ], # 0.5
      vibrance:           %w[ CIVibrance              inputAmount               ], # 1.0 - verify
      highlights:         %w[ CIHighlightShadowAdjust inputHighlightAmount      ], # 1.0
      shadows:            %w[ CIHighlightShadowAdjust inputShadowAmount         ], # 1.0 - verify
      sepia:              %w[ CISepiaTone             inputIntensity            ], # 1.0
      vignette_radius:    %w[ CIVignette              inputRadius               ], # 1.0
      vignette_intensity: %w[ CIVignette              inputIntensity            ], # 0.0
      pixellate_scale:    %w[ CIPixellate             inputScale                ], # 8.0
      pixellate_center:   %w[ CIPixellate             inputCenter               ], # [150, 150]
      wb_neutral:         %w[ CITemperatureAndTint    inputNeutral              ], # [6500, 0]
      wb_target_nautral:  %w[ CITemperatureAndTint    inputTargetNeutral        ], # [6500, 0]
      mono_color:         %w[ CIColorMonochrome       inputColor                ], # CIColor
      mono_intensity:     %w[ CIColorMonochrome       inputIntensity            ], # 1.0
      tint_color:         %w[ CIColorMonochrome       inputColor                ], # CIColor
      tint_intensity:     %w[ CIColorMonochrome       inputIntensity            ], # 1.0
      posterize:          %w[ CIColorPosterize        inputLevels               ], # 6.0
      lumi_sharp:         %w[ CISharpenLuminance      inputSharpness            ], # 0.4
      noise_reduce:       %w[ CIMedianFilter                                    ], # nil
      scale:              %w[ CILanczosScaleTransform inputScale                ], # 1.0
      aspect_ratio:       %w[ CILanczosScaleTransform inputAspectRatio          ], # 1.0
      crop:               %w[ CICrop                  inputRectangle            ], # [0, 0, 300, 300]
      straighten:         %w[ CIStraightenFilter      inputAngle                ], # 0 - verify
      df_p1:              %w[ CIDepthOfField          inputPoint1               ], # nil
      df_p2:              %w[ CIDepthOfField          inputPoint2               ], # nil
      df_radius:          %w[ CIDepthOfField          inputSaturation           ], # nil
      df_saturation:      %w[ CIDepthOfField          inputUnsharpMaskRadius    ], # nil
      df_mask_radius:     %w[ CIDepthOfField          inputUnsharpMaskIntensity ], # nil
      df_mask_intensity:  %w[ CIDepthOfField          inputRadius               ], # nil
      hue_angle:          %w[ CIHueAdjust             inputAngle                ], # 0..2pi - verify
    }.freeze

  end
end

=begin

CIDepthOfField
- inputPoint1               | The focused region of the image stretches in a line between inputPoint1 and inputPoint2 of the image. A CIVector object whose attribute type is CIAttributeTypePosition.
- inputPoint2               | A CIVector object whose attribute type is CIAttributeTypePosition.
- inputSaturation           | A saturation effect applied to the in-focus regions of the image. An NSNumber object whose attribute type is CIAttributeTypeScalar. This value indications the amount to adjust the saturation on the in-focus portion of the image.
- inputUnsharpMaskRadius    | Specifies the radius of the unsharp mask effect applied to the in-focus area. An NSNumber object whose attribute type is CIAttributeTypeScalar.
- inputUnsharpMaskIntensity | Specifies the intensity of the unsharp mask effect applied to the in-focus area. An NSNumber object whose attribute type is CIAttributeTypeScalar.
- inputRadius               | Controls how much the out-of-focus regions are blurred. An NSNumber object whose attribute type is CIAttributeTypeScalar. This value specifies the distance from the center of the effect.

=end
