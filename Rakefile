# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require

require 'under-os-camera'

Motion::Project::App.setup do |app|
  app.name       = 'uos-camera'
  app.identifier = 'com.under-os.camera'
  app.specs_dir  = './spec/lib'
  app.version    = UnderOs::Camera::VERSION

  app.codesign_certificate = ENV['RUBYMOTION_CERTIFICATE']
  app.provisioning_profile = ENV['RUBYMOTION_PROFILE']
end

