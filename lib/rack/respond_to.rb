module Rack

  # Based on Rails's API, and sinatra-respond_to (http://github.com/cehoffman/sinatra-respond_to)
  #
  # See examples/ directory for code examples.
  #
  module RespondTo
    class << self
      # Assign the environment directly to fetch the mime type from
      # env['HTTP_ACCEPT'] ('Accept:' request header).
      #
      # ===== Example
      #
      #   def call(env)
      #     Rack::RespondTo.env = env
      #   end
      #
      attr_accessor :env

      # If used completely standalone, you can assign the request mime_type directly.
      #
      # ===== Example
      #
      #   RespondTo.mime_type = 'application/xml'
      #
      attr_accessor :mime_type
      alias :media_type= :mime_type=
      alias :media_type  :mime_type

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
      #
      def mime_type(format = nil)
        @mime_type || accept
      end

      # Cast format to mime type
      #
      # ===== Example
      #
      #   RespondTo::MimeType('html') #=> 'text/html'
      #
      def MimeType(format)
        Rack::Mime.mime_type(format.sub(/^\./,'').insert(0,'.'))
      end

      private
        # The mime type retained from the HTTP_ACCEPT header's list
        #
        # ===== Returns
        # String:: first mime type from header's list or nil if none
        #
        def accept
          self.env['HTTP_ACCEPT'].split(',').first.split(';').first if env && env['HTTP_ACCEPT'] && !env['HTTP_ACCEPT'].empty?
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
      # to the current RespondTo.mime_type.
      #
      # ===== Example
      #
      #   RespondTo.mime_type = 'text/html'
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
        self[RespondTo::MimeType(format.to_s)] = handler
      end
    end
  end
end
