module UnderOs
  class Image
    VERSION = '0.0.0'

    def self.picker(options={})
      @picker ||= Picker.new(options)
    end

    def self.take(&block)
      picker.take(&block)
    end

    def self.pick(&block)
      picker.pick(&block)
    end

    attr_accessor :raw

    def initialize(raw_image)
      @raw = raw_image
    end
  end
end
