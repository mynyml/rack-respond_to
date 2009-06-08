# install required dependencies:
#   $sudo gem install mynyml-rack-abstract-format --source=http://gems.github.com/
#
# run with:
#   $rackup examples/recommended_use.ru -p 8080
#
# and request:
#   localhost:8080/foo.html
#   localhost:8080/foo.xml
#
require 'pathname'
root  =  Pathname(__FILE__).dirname.parent.expand_path
$:.unshift(root + 'lib')

require 'rubygems'
require 'rack'
require 'rack/abstract_format'
require 'rack/respond_to'

class App
  include Rack::RespondTo

  def call(env)
    Rack::RespondTo.env = env
    request = Rack::Request.new(env)

    body = case request.path_info
    when '/foo'
      respond_to do |format|
        format.html { '<em>html</em>' }
        format.xml  { '<body>xml</body>' }
      end
    end

    [200, {'Content-Type' => Rack::RespondTo.mime_type}, [body]]
  end
end

use Rack::AbstractFormat
run App.new

