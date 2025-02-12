platform :ios, '15.0'  # تم تحديث إصدار iOS الهدف

target 'Vrou' do
  use_frameworks!

  pod 'BSImagePicker', '~> 3.0'
  pod 'SwiftyJSON'
  pod 'Alamofire'
  pod 'PKHUD'
  pod 'RSSelectionMenu'
  pod 'IQKeyboardManagerSwift'
  pod 'RevealingSplashView'
  pod 'HCSStarRatingView'
  pod 'Tabman', '~> 1.10.2'
  pod 'ViewAnimator'
  pod 'ImageSlideshow', "~> 1.9.0"
  pod 'MXParallaxHeader'
  pod 'FSCalendar'
  pod 'SideMenu', '~> 6.0'
  pod 'collection-view-layouts/InstagramLayout'
  pod 'Shimmer'
  pod 'SDWebImage'
  pod 'AlamofireImage'
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
  pod 'netfox'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
        config.build_settings['CODE_SIGNING_REQUIRED'] = 'YES'
        config.build_settings['DEVELOPMENT_TEAM'] = 'YourTeamID'  # استبدل بـ Team ID الخاص بك
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
