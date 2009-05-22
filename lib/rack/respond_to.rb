module Rack

  # Based on Rails's API, and sinatra-respond_to (http://github.com/cehoffman/sinatra-respond_to)
  #
  # See examples/ directory for code examples.
  module RespondTo
    class << self
      # Assign the environment directly if it contains the format in
      # env['request.format']. This is useful in conjunction with other
      # middlewares that store the format in the env key.
      attr_accessor :env

      # If used completely standalone, you can assign the request format directly.
      #
      #   RespondTo.format = 'xml'
      attr_writer :format

      # Requested format
      def format
        (@format || self.env['request.format']).to_s.strip.downcase.sub(/^\./,'')
      end

      def included(base) #:nodoc:
        base.extend(ClassMethods)
        base.class_eval do
          include InstanceMethods
        end
      end

      # Convenience method that returns the mime type of the given format
      # (similar to Rack::Mime.mime_type).
      #
      # If format argument is omitted, will return the mime type for
      # RespondTo.format (i.e. equivelent to RespondTo.mime_type(RespondTo.format)).
      # Useful for setting content type:
      #
      # ===== Example
      #
      #   [200, {'Content-Type' => Rack::RespondTo.mime_type}, [body]]
      def mime_type(format = nil)
        format ||= self.format
        ext = format.sub(/^\./,'').insert(0,'.')
        Rack::Mime.mime_type(ext)
      end
    end

    module InstanceMethods
      # Delegates to the equivalent class method.
      def respond_to(&block)
        self.class.respond_to(&block)
      end
    end

    module ClassMethods
      # Allows defining different actions and returns the one which corresponds
      # to the current RespondTo.format.
      #
      # ===== Example
      #
      #   RespondTo.format = 'html'
      #
      #   respond_to do |format|
      #     format.html { '<em>html</em>' }
      #     format.xml  { '<content>xml</content>' }
      #   end
      #   #=> '<em>html</em>'
      #
      def respond_to(&block)
        format = Format.new
        block.call(format)
        handler = format[RespondTo.mime_type]
        handler.nil? ? nil : handler.call
      end
    end

    class Format < Hash #:nodoc:
      def method_missing(format, *args, &handler)
        self[RespondTo.mime_type(format.to_s)] = handler
      end
    end
  end
end
