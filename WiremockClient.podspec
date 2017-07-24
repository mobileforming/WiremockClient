Pod::Spec.new do |s|
  s.name             = 'WiremockClient'
  s.version          = '1.0.0'
  s.summary          = 'An HTTP client for iOS projects that allows users to modify the state of a standalone Wiremock instance from within an XCTestCase.'

  s.description      = <<-DESC
WiremockClient is an HTTP client for iOS projects that allows users to modify the state of a standalone Wiremock instance from within an XCTestCase.
                       DESC

  s.homepage         = 'http://mobileforming.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ted Rothrock' => 'ted.rothrock@mobileforming.com' }
  s.source           = { :git => '', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'WiremockClient/Classes/**/*'
end
