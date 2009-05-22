module Rack

  # Based on Rails's API, and sinatra-respond_to (http://github.com/cehoffman/sinatra-respond_to)
  #
  # See examples/app.ru for example use.
  module RespondTo
    class << self
      attr_accessor :env, :format

      def format
        (@format || self.env['request.format']).to_s.strip.downcase.sub(/^\./,'')
      end

      def included(base)
        base.extend(ClassMethods)
        base.class_eval do
          include InstanceMethods
        end
      end

      def mime_type(format = nil) #:nodoc:
        format ||= self.format
        ext = format.sub(/^\./,'').insert(0,'.')
        Rack::Mime.mime_type(ext)
      end
    end

    module InstanceMethods
      def respond_to(&block)
        self.class.respond_to(&block)
      end
    end

    module ClassMethods
      def respond_to(&block)
        format = Format.new
        block.call(format)
        handler = format[RespondTo.mime_type]
        handler.nil? ? nil : handler.call
      end
    end

    class Format < Hash
      def method_missing(format, *args, &handler)
        self[RespondTo.mime_type(format.to_s)] = handler
      end
    end
  end
end
