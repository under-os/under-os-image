class UnderOs::Image::Filter

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

    cg_image  = self.class.context.createCGImage(image, fromRect:image.extent)
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
    @filters = {}

    params.each do |key, value|
      filter     = filter_for(key)
      key, value = value_for(key, value)
      filter.setValue(value, forKey:key) if key
    end

    @filters.values
  end

  def filter_for(param)
    filter_name = FILTERS[param][0]

    if %w[tint_color tint_intensity].include?(param)
      @filters['tint_filter'] ||= CIFilter.filterWithName(filter_name)
    else
      @filters[filter] ||= CIFilter.filterWithName(filter_name)
    end
  end

  def value_for(key, value)
    value = case key
    when :contrast           then value
    when :brightness         then value
    when :saturation         then value
    when :exposure           then value
    when :vibrance           then value
    when :highlights         then value
    when :sepia              then value
    when :vignette_intensity then value + 2
    when :vignette_radius    then value + 1
    when :tint_intensity     then value
    when :tint_color         then color_for_angle(value)
    when :mono_intensity     then value
    when :mono_color         then CIColor.colorWithRed(value, green:value, blue:value, alpha:1.0)
    end

    value ? [FILTERS[key][1], value] : []
  end

  def color_for_angle(a)
    r, g, b = angle_2_rgb(a)
    CIColor.colorWithRed(r, green:g, blue:b, alpha:1.0)
  end

  def angle_2_rgb(a)
    x = 1 / 6.0
    s = a % x / x
    r = 1 - s

    if    a < x     then [1, 0, s]
    elsif a < x * 2 then [r, 0, 1]
    elsif a < x * 3 then [0, s, 1]
    elsif a < x * 4 then [0, 1, r]
    elsif a < x * 5 then [s, 1, 0]
    else                 [1, r, 0]
    end
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

=begin

CIDepthOfField
- inputPoint1               | The focused region of the image stretches in a line between inputPoint1 and inputPoint2 of the image. A CIVector object whose attribute type is CIAttributeTypePosition.
- inputPoint2               | A CIVector object whose attribute type is CIAttributeTypePosition.
- inputSaturation           | A saturation effect applied to the in-focus regions of the image. An NSNumber object whose attribute type is CIAttributeTypeScalar. This value indications the amount to adjust the saturation on the in-focus portion of the image.
- inputUnsharpMaskRadius    | Specifies the radius of the unsharp mask effect applied to the in-focus area. An NSNumber object whose attribute type is CIAttributeTypeScalar.
- inputUnsharpMaskIntensity | Specifies the intensity of the unsharp mask effect applied to the in-focus area. An NSNumber object whose attribute type is CIAttributeTypeScalar.
- inputRadius               | Controls how much the out-of-focus regions are blurred. An NSNumber object whose attribute type is CIAttributeTypeScalar. This value specifies the distance from the center of the effect.

=end
