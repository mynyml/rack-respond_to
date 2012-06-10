spec = Gem::Specification.new do |s|
  s.name                = "rack-respond_to"
  s.version             = "0.9.8"
  s.summary             = "Rack middleware port of Rails's respond_to feature"
  s.description         = "Rack middleware port of Rails's respond_to feature."
  s.author              = "Martin Aumont"
  s.email               = "mynyml@gmail.com"
  s.homepage            = "http://github.com/mynyml/rack-respond_to"
  s.rubyforge_project   = "rack-respond_to"
  s.has_rdoc            =  false
  s.require_path        = "lib"
  s.files               =  File.read("Manifest").strip.split("\n")

  s.add_dependency 'rack-accept-media-types', '>= 0.6'
  s.add_dependency 'rack'
  s.add_development_dependency 'minitest'
end
