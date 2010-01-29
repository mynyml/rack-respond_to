# install required dependency:
#   $sudo gem install rack-abstract-format
#
# run with:
#   $rackup examples/recommended_use.ru -p 8080
#
# and request:
#   localhost:8080/foo.html
#   localhost:8080/foo.xml
#
require 'pathname'
$:.unshift Pathname(__FILE__).dirname.parent + 'lib'

require 'rack'
require 'rack/abstract_format'
require 'rack/respond_to'

class App
  include Rack::RespondTo

  def call(env)
    Rack::RespondTo.env = env
    request = Rack::Request.new(env)

    body = case request.path_info
    when '/'
      "try /foo<em>.html</em> and /foo<em>.xml</em>"
    when '/foo'
      respond_to do |format|
        format.html { '<em>html</em>' }
        format.xml  { '<body>xml</body>' }
      end
    end

    [200, {'Content-Type' => Rack::RespondTo.selected_media_type || 'text/html'}, [body || '']]
  end
end

use Rack::AbstractFormat
run App.new
