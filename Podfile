# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

source 'https://github.com/CocoaPods/Specs.git'

def base_modules
  pod 'BLTBasicUIKit', :git => 'git@github.com:mushanlianshi/BLTBasicUIKit.git', :tag => '0.3.1'
  pod 'BLTUIKitProject', :git => 'git@github.com:mushanlianshi/BLTUIKitProject.git', :tag => '1.9.2'
  pod 'BLTSwiftUIKit', :git => 'git@github.com:mushanlianshi/BLTSwiftUIKit.git', :tag => '1.3.8'
  pod 'BLTPublicModules', :git => 'git@github.com:mushanlianshi/BLTPublicModules.git', :tag => '0.3.6'
end

target 'LBEBayDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  base_modules
  pod 'AFNetworking', '~> 4.0'
  pod 'MJRefresh', '~> 3.7.5'
  # SnapKit 5.0需要iOS10.0 所以导入4.2.0
  pod 'SnapKit', '= 4.2.0'
  #5.0以后需要iOS10
  pod 'Kingfisher', '= 4.9.0'
  pod 'MBProgressHUD', '1.1.0'
  pod 'MJExtension',   '3.0.17'
  pod 'IGListKit'
  pod 'LookinServer', '= 1.0.6', :configurations => ['Debug']
  target 'LBEBayDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LBEBayDemoUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
#      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
      
      #适配Xcode15 cocospod大于1.14.2就不需要了
#      xcconfig_path = config.base_configuration_reference.real_path
#      xcconfig = File.read(xcconfig_path)
#      xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
#      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
    end
  end
end
