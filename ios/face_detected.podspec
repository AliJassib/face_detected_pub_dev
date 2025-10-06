#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint face_detected.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'face_detected'
  s.version          = '0.0.1'
  s.summary          = '**Face Verification** is a comprehensive Flutter package that provides intelligent face verification capabilities with multi-step authentication using facial expressions and gestures. This package combines advanced machine learning face detection with user-friendly verification workflows, making it perfect for secure authentication, identity verification, and interactive camera applications.'
  s.description      = <<-DESC
**Face Verification** is a comprehensive Flutter package that provides intelligent face verification capabilities with multi-step authentication using facial expressions and gestures. This package combines advanced machine learning face detection with user-friendly verification workflows, making it perfect for secure authentication, identity verification, and interactive camera applications.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'face_detected_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
