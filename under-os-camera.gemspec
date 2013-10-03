# -*- encoding: utf-8 -*-
require File.expand_path('../lib/under_os_camera', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "under-os-camera"
  gem.version       = UnderOs::Camera::VERSION

  gem.authors       = ["Nikolay Nemshilov"]
  gem.email         = ['nemshilov@gmail.com']
  gem.description   = "Camera and image albums related hooks for UnderOs"
  gem.summary       = "Camera and image albums related hooks for UnderOs"
  gem.license       = 'MIT'

  gem.files         = Dir['lib/**/*']

  gem.add_runtime_dependency 'under-os'#, path: '../under-os'

  gem.add_development_dependency 'rake'
end
