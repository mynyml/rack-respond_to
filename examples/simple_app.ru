# run me with:
#   $rackup examples/simple_app.ru
#
require 'pathname'
$:.unshift Pathname(__FILE__).dirname.parent + 'lib'

require 'rack'
require 'rack/respond_to'

class App
  include Rack::RespondTo

  def call(env)
    Rack::RespondTo.media_types = %w( application/xml )

    body = case env['PATH_INFO']
    when '/'
      respond_to do |format|
        format.html { '<em>html</em>' }
        format.xml  { '<body>xml</body>' }
      end
    end

    [200, {'Content-Type' => Rack::RespondTo.selected_media_type || ''}, [body || '']]
  end
end

run App.new
