Pod::Spec.new do |spec|
  spec.name = "GAuth"
  spec.version = "0.1.0"
  spec.summary = "Authentication to Google services made easy."
  spec.homepage = "https://www.github.com/fabiomassimo/GAuth"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Fabio Milano" => 'fabio@touchwonders.com' }
  spec.social_media_url = "http://twitter.com/iamfabiomilano"

  spec.ios.deployment_target = '9.0'
  spec.tvos.deployment_target = '9.0'
  spec.watchos.deployment_target = '2.0'
  
  spec.requires_arc = true
  spec.source = { git: "https://www.github.com/fabiomassimo/GAuth", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "Sources/**/*.{h,swift}"

  spec.dependency "Result", "~> 2.1"
end