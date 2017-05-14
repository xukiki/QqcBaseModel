Pod::Spec.new do |s|

  s.license      = "MIT"
  s.author       = { "qqc" => "20599378@qq.com" }
  s.platform     = :ios, "8.0"
  s.requires_arc  = true

  s.name         = "QqcBaseModel"
  s.version      = "1.0.0"
  s.summary      = "QqcBaseModel"
  s.homepage     = "https://github.com/xukiki/QqcBaseModel"
  s.source       = { :git => "https://github.com/xukiki/QqcBaseModel.git", :tag => "#{s.version}" }
  
  s.source_files  = ["QqcBaseModel/*.{h,m}"]

end
