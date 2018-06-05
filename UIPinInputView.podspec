#
#  Be sure to run `pod spec lint UIPinInputView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "UIPinInputView"
  s.version      = "0.1.0"
  s.summary      = "Customizable OTP input view for iOS applications."

  s.description  = <<-DESC
  Customizable OTP input view for iOS applications.
                   DESC

  s.homepage     = "https://github.com/Rashidium/UIPinInputView"

  s.license      = "MIT"

  s.author             = { "RashidRamazanov" => "rashid.ramazanov@magis.com.tr" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/Rashidium/UIPinInputView.git", :tag => "#{s.version}" }

  s.source_files  = "UIPinInputView", "UIPinInputView/**/*.{h,m,swift}"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0.0' }

end
