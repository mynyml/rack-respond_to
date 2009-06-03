# run me with:
#   $rackup examples/simple_app.ru -p 8080
#
require 'pathname'
root  =  Pathname(__FILE__).dirname.parent.expand_path
$:.unshift(root + 'lib')

require 'rubygems'
require 'rack'
require 'rack/respond_to'

class App
  include Rack::RespondTo

  def call(env)
    Rack::RespondTo.mime_type = 'application/xml'

    body = case env['PATH_INFO']
    when '/'
      respond_to do |format|
        format.html { '<em>html</em>' }
        format.xml  { '<body>xml</body>' }
      end
    end

    [200, {'Content-Type' => Rack::RespondTo.mime_type}, [body]]
  end
end

run App.new
