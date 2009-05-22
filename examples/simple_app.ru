# run me with:
#   $rackup examples/simple_app.ru -p 8080
#
require 'pathname'
root  =  Pathname(__FILE__).dirname.parent.expand_path
$:.unshift(root.join('lib'))

require 'rubygems'
require 'rack'
require 'rack/respond_to'

class App
  include Rack::RespondTo

  def call(env)
    # simply pass in the env if another middleware already added
    # the format to env['request.format']
    #Rack::RespondTo.env = env

    # otherwise, you can assign it directly
    Rack::RespondTo.format = 'html'

    body = case env['PATH_INFO']
    when '/'
      respond_to do |format|
        format.html { '<em>html</em>' }
        format.xml  { '<body>xml</body>' }
      end
    end

    content_type = Rack::RespondTo.mime_type
    [200, {'Content-Type' => content_type}, [body]]
  end
end

run App.new
