require 'pathname'
require 'test/unit'
require 'rubygems'
require 'rack'
begin
  require 'ruby-debug'
rescue LoadError, RuntimeError
end

root = Pathname(__FILE__).dirname.parent.expand_path
$:.unshift(root.join('lib'))

require 'rack/respond_to'

class Test::Unit::TestCase
  def self.test(name, &block)
    name = :"test_#{name.gsub(/\s/,'_')}"
    define_method(name, &block)
  end
end
