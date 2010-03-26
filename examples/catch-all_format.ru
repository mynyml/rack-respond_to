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
    Rack::RespondTo.media_types = %w( text/html application/xml )

    body = case env['PATH_INFO']
    when '/'
      respond_to do |format|
        format.txt { 'txt' }
        format.rss { 'rss' }
        format.any { 'unsuported format' }
      end
    end

    [200, {'Content-Type' => Rack::RespondTo.selected_media_type || ''}, [body || '']]
  end
end

run App.new
