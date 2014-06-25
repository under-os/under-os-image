# -*- encoding: utf-8 -*-
require File.expand_path('../lib/under_os/image/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "under-os-image"
  gem.version       = UnderOs::Image::VERSION

  gem.authors       = ["Nikolay Nemshilov"]
  gem.email         = ['nemshilov@gmail.com']
  gem.description   = "The images handling API for UnderOS"
  gem.summary       = "The images handling API for UnderOS. For real"
  gem.license       = 'MIT'

  gem.files         = Dir['lib/**/*']

  gem.add_runtime_dependency 'under-os-ui'

  gem.add_development_dependency 'rake'
end
