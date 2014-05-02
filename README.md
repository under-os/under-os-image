# UnderOS Image

The new simplified images processing API for the [http://under-os.com](under-os) project

Basically it's a wrapper over the `UIImage` and the `CoreImage` library to help me to deal
with routine things like image picking, resizing and filtering

## Basic Functionality

```ruby
@image = UOS::Image.new(UIImage.alloc.imageWithName("test.png"))

@image.resize UOS::Screen.size
@image.filter(brightness: 0.5, contrast: 0.8)
```

## Picking & Taking

To make things easier the `UOS::Image` class has two methods `#take` and `#pick`
which will bring in the native iOS image picker/camera modules to quickly get you going

```ruby
UOS::Image.take do |image|
  # captures the image from the camera
end

UOS::Image.pick do |image|
  # picks the image from the image picker
end
```


# Copyright & License

All code in this library is released under the terms of the MIT license

Copyright (C) 2013-14 Nikolay Nemshilov
