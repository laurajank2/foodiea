# Uncomment the next line to define a global platform for your project
ENV['SWIFT_VERSION'] = '5'
platform :ios, '13.0'

pre_install do |installer|
    installer.analysis_result.specifications.each do |s|
        if s.name == 'GIFImageView'
            s.swift_version = '5'
        end
    end
end

pre_install do |installer|
    installer.analysis_result.specifications.each do |s|
        if s.name == 'EnlargedThumbSlider'
            s.swift_version = '5'
        end
    end
end

target 'Foodiea' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Foodiea
pod 'Parse'
pod 'Parse/UI'
pod 'MKDropdownMenu'
pod 'UITextView+Placeholder'
 pod 'DateTools'
pod 'GoogleMaps', '7.0.0'
pod 'GooglePlaces', '7.0.0'
pod 'StepSlider', '~> 1.8.0'
pod 'GIFImageView'
pod 'EnlargedThumbSlider'

  target 'FoodieaTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FoodieaUITests' do
    # Pods for testing
  end

end
