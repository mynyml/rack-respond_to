require 'rack/accept_media_types'

module Rack

  # Based on Rails's API, and sinatra-respond_to (http://github.com/cehoffman/sinatra-respond_to)
  #
  # See examples/ directory for code examples.
  #
  module RespondTo
    class << self
      # Assign the environment directly to fetch the requested media types from
      # env['HTTP_ACCEPT'] ('Accept:' request header).
      #
      # ===== Example
      #
      #   def call(env)
      #     Rack::RespondTo.env = env
      #     #...
      #   end
      #
      attr_accessor :env

      # If used completely standalone, you can assign the requested media types
      # directly.
      #
      # ===== Example
      #
      #   RespondTo.media_types = ['application/xml']
      #
      attr_writer :media_types
      alias :mime_types= :media_types=

      # Contains the media type that was responded to. Set after the respond_to
      # block is called.
      #
      # Useful for setting the response's Content-Type:
      #
      #   [200, {'Content-Type' => RespondTo.selected_media_type}, [body]]
      #
      attr_accessor :selected_media_type
      alias :selected_mime_type= :selected_media_type=
      alias :selected_mime_type  :selected_media_type

      def included(base) #:nodoc:
        base.extend(ClassMethods)
        base.class_eval do
          include InstanceMethods
        end
      end

      # Cast format to media type
      #
      # ===== Example
      #
      #   RespondTo::MediaType('html') #=> 'text/html'
      #   RespondTo::MediaType('htm')  #=> 'text/html'
      #
      def MediaType(format)
        Rack::Mime.mime_type(format.sub(/^\./,'').insert(0,'.'))
      end
      alias :MimeType :MediaType

      # Requested media types, in preferencial order
      #
      # ===== Examples
      #
      #   RespondTo.env['HTTP_ACCEPT'] #=> 'text/html,application/xml'
      #   RespondTo.media_types        #=> ['text/html', 'application/xml']
      #
      #   RespondTo.env['HTTP_ACCEPT'] #=> 'text/html;q=0.7,application/xml;q=0.9,application/json;q=0.8'
      #   RespondTo.media_types        #=> ['application/xml', 'application/json', 'text/html']
      #
      def media_types
        @media_types || accept_list
      end
      alias :mime_types :media_types

      private
        def accept_list
          self.env.nil? ? [] : Rack::AcceptMediaTypes.new(self.env['HTTP_ACCEPT'] || '')
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
      # to the highest ranking value in the RespondTo.media_types list.
      #
      # If no handler is defined for the highest ranking value, respond_to will
      # cascade down the RespondTo.media_types list until it finds a match.
      # Returns nil if there is no match.
      #
      # Wildcard media types (*/*, text/*, etc.) will trigger the first
      # matching format definition, so order matters if you expect the Accept
      # header to contain any (a nil Accept header, for instance, will be
      # turned into '*/*' as per rfc2616-sec14.1). Simply define the 'default'
      # handler first (usually html), and it will work like a charm.
      #
      # ===== Examples
      #
      #   RespondTo.media_types = ['text/html', 'application/xml']
      #
      #   respond_to do |format|
      #     format.html { 'html' }
      #     format.xml  { 'xml'  }
      #   end
      #   #=> 'html'
      #
      #   RespondTo.media_types = ['text/html', 'application/xml']
      #
      #   respond_to do |format|
      #     format.xml  { 'xml' }
      #     format.txt  { 'txt'  }
      #   end
      #   #=> 'xml'
      #
      #   RespondTo.media_types = ['text/html', 'application/json']
      #
      #   respond_to do |format|
      #     format.xml  { 'xml' }
      #     format.txt  { 'txt'  }
      #   end
      #   #=> nil
      #
      #   RespondTo.media_types = ['*/*']
      #
      #   respond_to do |format|
      #     format.html { 'html' }
      #     format.xml  { 'xml'  }
      #   end
      #   #=> 'html'
      #
      #   RespondTo.media_types = ['*/*']
      #
      #   respond_to do |format|
      #     format.xml  { 'xml'  }
      #     format.html { 'html' }
      #   end
      #   #=> 'xml'
      #
      #   RespondTo.media_types = ['text/*']
      #
      #   respond_to do |format|
      #     format.xml  { 'xml'  } # application/xml  (skip)
      #     format.html { 'html' } # text/html        (match)
      #     format.txt  { 'txt'  }
      #   end
      #   #=> 'html'
      #
      def respond_to
        format = Format.new
        yield format
        type, handler = Helpers.match(RespondTo.media_types, format)
        RespondTo.selected_media_type = type
        handler.nil? ? nil : handler.call
      end
    end

    # Helper methods, kept in a seperate namespace to avoid pollution.
    module Helpers #:nodoc:
      extend self

      # TODO refactor
      def match(media_types, format)
        selected = []
        accepted_types = media_types.map {|type| Regexp.escape(type).gsub(/\\\*/,'.*') }
        accepted_types.each do |at|
          format.each do |ht, handler|
            (selected = [ht, handler]) and break if ht.match(at)
          end
          break unless selected.empty?
        end
        selected
      end
    end

    # NOTE
    # Array instead of hash because order matters (wildcard type matches first
    # handler)
    class Format < Array #:nodoc:
      def method_missing(format, *args, &handler)
        self << [RespondTo::MediaType(format.to_s), handler]
      end
    end
  end
end
