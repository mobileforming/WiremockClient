Pod::Spec.new do |s|
  s.name             = 'WiremockClient'
  s.version          = '1.2.0'
  s.summary          = 'An HTTP client for Wiremock standalone instances'

  s.description      = <<-DESC
WiremockClient is an HTTP client that allows users to interact with a standalone Wiremock instance from within an Xcode project.
                       DESC

  s.homepage         = 'http://mobileforming.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ted Rothrock' => 'ted.rothrock@mobileforming.com' }
  s.source           = { :git => 'https://github.com/jamf/WiremockClient.git', :tag => '1.2.0' }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'WiremockClient/Classes/**/*'
end
