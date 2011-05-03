require 'test/test_helper'

class App
  include Rack::RespondTo
end

class TestRespondTo < MiniTest::Unit::TestCase

  def setup
    Rack::RespondTo.selected_media_type = nil
    Rack::RespondTo.media_types = nil
    Rack::RespondTo.env = nil
  end

  ## api

  test "env accessor" do
    env = {'HTTP_ACCEPT' => 'text/html,application/xml'}
    Rack::RespondTo.env = env
    assert_equal env, Rack::RespondTo.env
  end

  test "media types accessor" do
    Rack::RespondTo.media_types = %w( application/xml )
    assert_equal %w( application/xml ), Rack::RespondTo.media_types
    assert_equal %w( application/xml ), Rack::RespondTo.mime_types  #alias
  end

  test "selected media type reader" do
    Rack::RespondTo.media_types = %w( application/xml )
    body = App.respond_to do |format|
      format.xml { 'xml' }
    end
    assert_equal 'application/xml', Rack::RespondTo.selected_media_type
    assert_equal 'application/xml', Rack::RespondTo.selected_mime_type  #alias
  end

  test "mixin injects respond_to class method" do
    assert App.respond_to?(:respond_to)
  end

  test "mixin injects respond_to instance method" do
    assert App.new.respond_to?(:respond_to)
  end

  ## requested media types

  test "explicitly specified media types take precedence over header's" do
    Rack::RespondTo.env = {'HTTP_ACCEPT' => 'text/html'}
    Rack::RespondTo.media_types = %w( text/plain )
    assert_equal %w( text/plain ), Rack::RespondTo.media_types
  end

  test "explicitly specified headers in the media types take precedence over other media types" do
    Rack::RespondTo.env = {'HTTP_ACCEPT' => 'text/html'}
    Rack::RespondTo.media_types = %w( text/plain text/html)
    assert_equal %w( text/html ), Rack::RespondTo.media_types
  end


  ## respond_to

  test "respond_to returns block for highest ranking format" do
    Rack::RespondTo.env = {'HTTP_ACCEPT' => 'application/xml;q=0.8,text/plain;q=0.9'}
    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal 'txt', body
  end

  test "cascades down the Accept header's list to find suitable type" do
    Rack::RespondTo.env = {'HTTP_ACCEPT' => 'text/html,text/plain;q=0.9'}
    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal 'txt', body
  end

  test "respond_to with no matching format" do
    Rack::RespondTo.media_types = %w( text/html )
    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal nil, body
  end

  test "respond_to with empty type list" do
    Rack::RespondTo.media_types = []
    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal nil, body
  end

  test "respond_to with nil type list" do
    Rack::RespondTo.media_types = nil
    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal nil, body
  end

  test "respond_to handles synonymous formats" do
    Rack::RespondTo.media_types = %w( text/html )

    body = App.respond_to do |format|
      format.htm { 'htm' } # htm/html
      format.xml { 'xml' }
    end
    assert_equal 'htm', body

    body = App.respond_to do |format|
      format.html { 'html' } # htm/html
      format.json { 'json' }
    end
    assert_equal 'html', body
  end

  test "respond_to handles types with special chars" do
    Rack::RespondTo.media_types = %w( application/rss+xml )
    body = App.respond_to do |format|
      format.rss { 'rss' }
    end
    assert_equal 'rss', body

    Rack::RespondTo.media_types = %w( video/x-msvideo )
    body = App.respond_to do |format|
      format.avi { 'avi' }
    end
    assert_equal 'avi', body

    Rack::RespondTo.media_types = %w( application/x-bzip2 )
    body = App.respond_to do |format|
      format.bz2 { 'bz2' }
    end
    assert_equal 'bz2', body
  end

  test "repond_to sets selected media type" do
    Rack::RespondTo.media_types = %w( text/html text/plain )
    assert_equal nil, Rack::RespondTo.selected_media_type
    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal 'txt', body
    assert_equal 'text/plain', Rack::RespondTo.selected_media_type
  end

  ## wildcard media types

  test "wildcard type matches first handler" do
    Rack::RespondTo.media_types = %w( */* )

    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal 'xml', body

    body = App.respond_to do |format|
      format.txt { 'txt' }
      format.xml { 'xml' }
    end
    assert_equal 'txt', body
  end

  test "wildcard subtype matches first handler for type" do
    Rack::RespondTo.media_types = %w( text/* )

    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
      format.htm { 'htm' }
    end
    assert_equal 'txt', body

    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.htm { 'htm' }
      format.txt { 'txt' }
    end
    assert_equal 'htm', body

    body = App.respond_to do |format|
      format.xml { 'xml' }
    end
    assert_equal nil, body
  end

  ## catch-all format

  test "catch-all format" do
    Rack::RespondTo.media_types = %w( text/html application/xml )

    body = App.respond_to do |format|
      format.txt { 'txt' }
      format.avi { 'avi' }
      format.any { 'any' }
    end
    assert_equal 'any', body
    assert_equal 'text/html', Rack::RespondTo.selected_media_type

    body = App.respond_to do |format|
      format.htm { 'htm' }
      format.xml { 'xml' }
      format.any { 'any' }
    end
    assert_equal 'htm', body
    assert_equal 'text/html', Rack::RespondTo.selected_media_type
  end
end
