Pod::Spec.new do |s|
  s.name         = "CoordinatorKitSwift"
  # Version goes here and will be used to access the git tag later on, once we have a first release.
  s.version      = "1.2"
  s.summary      = "iOS architecture framework"
  s.description  = <<-DESC
                   Swift library for architecting iOS applications using the
                   coordinator pattern.
                   DESC
  s.homepage     = "https://github.com/startupthekid/CoordinatorKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "startupthekid"

  s.ios.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/startupthekid/CoordinatorKit.git", :tag => "v#{s.version}" }

  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = "CoordinatorKit/Core/*.{swift}"
    ss.framework = "Foundation"
  end

  s.pod_target_xcconfig = {"OTHER_SWIFT_FLAGS[config=Release]" => "-suppress-warnings" }
end
