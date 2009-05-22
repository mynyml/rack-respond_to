# install required dependencies:
#
#   $sudo gem install rack-rack-contrib --source=http://gems.github.com/
#   $sudo gem install mynyml-rack-abstract-format --source=http://gems.github.com/
#
# and run me with:
#   $rackup examples/recommended_use.ru -p 8080
#
require 'rubygems'
require 'rack'
require 'rack/contrib' # for Rack::AcceptFormat
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

    content_type = Rack::RespondTo.mime_type
    [200, {'Content-Type' => content_type}, [body]]
  end
end

use Rack::AcceptFormat
use Rack::AbstractFormat
run App.new

