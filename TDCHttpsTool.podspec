Pod::Spec.new do |s|
    s.name         = 'TDCHttpsTool'
    s.version      = '1.0.5'
    s.summary      = '一套适用于今日城市的网络基础库'
    s.homepage     = 'https://github.com/coderCX/TDCHttpsTool'
    s.license      = 'MIT'
    s.authors      = {'程曦' => '460018082@qq.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/coderCX/TDCHttpsTool.git', :tag => s.version}
    s.source_files = 'TDCHttpsTool/**/*.{h,m}'
    s.resource     = 'TDCHttpsTool/*'
    s.requires_arc = true

    s.public_header_files = 'TDCHeader.h'
    s.source_files = 'TDCHeader.h' 

    s.dependency  'AFNetworking'
    s.dependency  'SDWebImage'
    s.dependency  'SAMKeychain'
    s.dependency  'Reachability'

    #s.prefix_header_contents = "#import <AFNetworking/AFNetworking.h>"
    #s.prefix_header_contents = "#import <SDWebImage/UIImageView+WebCache.h>"
    #s.prefix_header_contents = "#import <SAMKeychain/SAMKeychain.h>"
    #s.prefix_header_contents = "#import <Reachability/Reachability.h>"
end
