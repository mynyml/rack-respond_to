--- !ruby/object:Gem::Specification 
name: rack-respond_to
version: !ruby/object:Gem::Version 
  version: 0.9.5
platform: ruby
authors: 
- Martin Aumont
autorequire: 
bindir: bin
cert_chain: []

date: 2009-06-08 00:00:00 -04:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: mynyml-rack-accept-media-types
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0.6"
    version: 
description: Rack middleware port of Rails's respond_to feature
email: mynyml@gmail.com
executables: []

extensions: []

extra_rdoc_files: []

files: 
- Rakefile
- test
- test/test_respond_to.rb
- test/test_helper.rb
- examples
- examples/simple_app.ru
- examples/recommended_use.ru
- TODO
- lib
- lib/rack
- lib/rack/respond_to.rb
- rack-respond_to.gemspec
- LICENSE
- README
has_rdoc: true
homepage: ""
licenses: []

post_install_message: 
rdoc_options: []

require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
requirements: []

rubyforge_project: 
rubygems_version: 1.3.3
signing_key: 
specification_version: 3
summary: Rack middleware port of Rails's respond_to feature
test_files: []

