Summary
-------
Rack convenience middleware that allows triggering different actions based on
requested media type. Standalone version of the equivalent Rails functionality.

Features
--------
* Based on familiar API (Rails)
* Cascades down priority list of accepted media types
* Handles wildcard media types
* Simple to use
* Simple code (~50 LOCs)
* Flexible (standalone use)
* Decently documented (examples/ dir, source docs/rdocs)
* Compatible with other media type handling middleware (uses Rack::AcceptMediaTypes)

Install
-------

    gem install rack-respond_to

Example
-------

    require 'rack'
    require 'rack/respond_to'

    class App
      include Rack::RespondTo #mixes in #respond_to

      def call(env)
        # Pass in the env, and RespondTo will retrieve the requested media types
        Rack::RespondTo.env = env

        # Alternatively, to use standalone you can also assign the media types
        # directly (this will take precedence over the env)
        #Rack::RespondTo.media_types = ['text/html']

        body = respond_to do |format|
          format.html { '<em>html</em>' }
          format.xml  { '<body>xml</body>' }
        end

        [200, {'Content-Type' => Rack::RespondTo.selected_media_type}, [body]]
      end
    end

    run App.new

See `examples/simple_app.ru` for an executable example.

Tips
----
Use together with `Rack::AbstractFormat` to respond to routes based on url
extensions. For example, if you want `example.com/foo.xml` to trigger the
`format.xml` block (`Rack::AbstractFormat` moves the extension's media type
into `HTTP_ACCEPT` and makes it the highest ranked).

  `gem install rack-abstract-format`

See `examples/recommended_use.ru` for a complete example.

Acknowledgement
---------------
* thanks to [daicoden][1] for `format.any` idea and initial patch

Links
-----

* code: http://github.com/mynyml/rack-respond_to
* docs: http://docs.github.com/mynyml/rack-respond_to
* bugs: http://github.com/mynyml/rack-respond_to/issues


[1]: http://github.com/daicoden
