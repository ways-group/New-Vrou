platform :ios, '14.0'

target 'Vrou' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

pod 'BSImagePicker', '~> 3.0'
pod 'SwiftyJSON'
pod 'Alamofire', '~> 4.7.3'
pod 'PKHUD'
pod 'RSSelectionMenu'
pod 'IQKeyboardManagerSwift'
pod 'RSSelectionMenu'
pod 'RevealingSplashView'
pod 'HCSStarRatingView'
pod 'Tabman', '~> 1.10.2'
pod 'ViewAnimator'
pod 'ImageSlideshow', "~> 1.7.0"
pod 'MXParallaxHeader'
pod 'FSCalendar'
pod 'SideMenu', '~> 6.0'
pod 'collection-view-layouts/InstagramLayout'
pod 'Shimmer'
pod 'SDWebImage'
pod 'AlamofireImage', "~> 3.4.1"
pod 'GoogleMaps', '8.0.0'
pod 'GooglePlaces', '8.0.0'
pod 'ImageSlideshow/Alamofire'
pod 'MOLH'
pod 'SwipeCellKit'
pod 'XLPagerTabStrip', '~> 9.0'
pod 'FirebaseMessaging'
pod 'FirebaseAnalytics'
pod 'FirebasePerformance'
pod 'FirebaseCrashlytics'
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'GoogleSignIn'
pod 'ActiveLabel'
pod 'MultiSlider'
pod 'FacebookCore'
pod 'FacebookLogin'
pod 'FacebookShare'

    post_install do |installer|
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        end
      end
      
      installer.pods_project.targets.each do |target|
        if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
          target.build_configurations.each do |config|
              config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
          end
        end
      end
      
    end

end
