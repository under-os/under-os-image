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

    attr_accessor :_

    def initialize(raw_image)
      @_ = raw_image
    end

    def filter(params)
      @filter ||= Filter.new.tap{ |f| f.image = self }
      @filter.params = params
      @filter.apply
    end
  end
end
