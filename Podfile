source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/dafiger/DFPublicSpec.git'

platform :ios, '8.0'
#inhibit_all_warnings!
#use_frameworks!

target 'JSAndNativeDemo' do

	# 常用库
	# pod 'Masonry', '~> 1.1.0'
	# pod 'AFNetworking', '~> 3.2.1'
	# pod 'YYModel', '~> 1.0.4'
	# pod 'SDWebImage', '~> 4.4.6'
	# pod 'MBProgressHUD', '~> 1.1.0'
	# RAS(纯Swift)
	# pod 'ReactiveCocoa', '~> 10.0.0'
	# pod 'ReactiveSwift', '~> 6.0.0'
	# RAC(纯OC)
	# pod 'ReactiveObjC', '~> 3.1.1'
	# RAC&RAS(混合开发)
	# pod 'ReactiveObjC', '~> 3.1.1'
	# pod 'ReactiveCocoa', '~> 10.0.0'
	# pod 'ReactiveObjCBridge', '~> 4.0.0'

	# 布局
	# pod 'SDAutoLayout', '~> 2.1.3'
	# TableView
	# pod 'UITableView+FDTemplateLayoutCell', '~> 1.6'
	# 天猫高性能异构滚动视图构建方案
   	# pod 'LazyScrollView', '~> 1.0.0'
	# 组件化框架
	# pod ’CTMediator‘
	# pod 'MGJRouter', '~>0.9.0'
	# pod 'JLRoutes', '~> 2.1'
	# 函数响应式编程
	# pod 'ReactiveCocoa', '~> 8.0.2'
	# pod 'ReactiveObjC', '~> 3.1.0'
	# 网络
	# pod 'Reachability', '~> 3.2'
	# pod 'YTKNetwork', '~> 2.0.4'
	# pod 'SVProgressHUD', '~> 2.2.5'
	# pod 'MJRefresh', '~> 3.1.15.7'
	# pod 'CocoaAsyncSocket', '~> 7.6.3'
	# 空视图占位
	# pod 'DZNEmptyDataSet', '~> 1.8.1'
	# 数据库
	# pod 'FMDB', '~> 2.7.5'
	# 图片轮播
	# pod 'SDCycleScrollView', '~> 1.80'
	# pod 'JXBAdPageView', '~> 1.5'
	# 新闻头条联动
	# pod 'ZJScrollPageView', '~> 0.4.0'
	# 友盟
	# pod 'UMengAnalytics', '~> 4.2.4'
	# pod 'UMengAnalytics-NO-IDFA', '~> 4.2.5'
    # 百度地图
	# pod 'BaiduMapKit', '~> 3.2'
	# 视频播放器
	# pod 'MobileVLCKit', '~> 2.2.2'
	# pod 'MobileVLCKit'
	# pod 'MobileVLCKit', '~> 3.3.2'
	# 键盘助手
	# pod 'IQKeyboardManager', '~> 6.3.0'

	# 本地库
	# pod 'BasePlug', :path => '../Lib/BasePlug'
	# pod 'BasePlug', :git => ‘https://github.com/dafiger/BasePlug.git'
	# 引入部分库
	# pod 'FFBaseKit/Category' 
	# pod 'FFBaseKit', :subspecs => ['Category', 'Tools']
	# pod 'YTXAnimations', '~> 1.2.4', :subspecs => ["AnimateCSS", "Transformer"]

end

# pod update --no-repo-update
# 实现post_install Hooks
post_install do |installer|
# puts 为在终端打印方法
puts "##### post_install start #####"

  # # 1. 遍历项目中所有target
  installer.pods_project.targets.each do |target|
    # 2. 遍历build_configurations
    target.build_configurations.each do |config|
      # 3. 修改build_settings中的ENABLE_BITCODE
      config.build_settings['ENABLE_BITCODE'] = 'NO'

      # config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'

      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 8.0
      	 config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
      end

    end

  end
    
puts "##### post_install end #####"
end
