require 'test/test_helper'

class App
  include Rack::RespondTo
end

class TestRespondTo < Test::Unit::TestCase

  def setup
    Rack::RespondTo.mime_type = nil
  end

  ## api

  test "env accessor" do
    env = {'HTTP_ACCEPT' => 'text/html,application/xml'}
    Rack::RespondTo.env = env
    assert_equal env, Rack::RespondTo.env
  end

  test "mime type accessor" do
    Rack::RespondTo.mime_type = 'application/xml'
    assert_equal 'application/xml', Rack::RespondTo.mime_type

    # alias
    Rack::RespondTo.media_type = 'application/xml'
    assert_equal 'application/xml', Rack::RespondTo.media_type
  end

  test "mixin injects respond_to class method" do
    assert App.respond_to?(:respond_to)
  end

  test "mixin injects respond_to instance method" do
    assert App.new.respond_to?(:respond_to)
  end

  ## mime type

  test "mime type is extracted from header (first in list)" do
    Rack::RespondTo.env = {'HTTP_ACCEPT' => 'text/html,application/xml'}
    assert_equal 'text/html', Rack::RespondTo.mime_type

    Rack::RespondTo.env = {'HTTP_ACCEPT' => 'application/xml,text/html'}
    assert_equal 'application/xml', Rack::RespondTo.mime_type
  end

  test "mime type with empty header" do
    assert_nothing_raised do
      Rack::RespondTo.env = {'HTTP_ACCEPT' => ''}
      Rack::RespondTo.mime_type = nil
      assert_equal nil, Rack::RespondTo.mime_type
    end
  end

  test "mime type with nil header" do
    assert_nothing_raised do
      Rack::RespondTo.env = {}
      Rack::RespondTo.mime_type = nil
      assert_equal nil, Rack::RespondTo.mime_type
    end
  end

  test "mime type without source" do
    assert_nothing_raised do
      Rack::RespondTo.env = nil
      Rack::RespondTo.mime_type = nil
      assert_equal nil, Rack::RespondTo.mime_type
    end
  end

  test "explicitly specified mime type takes precedence over env's" do
    Rack::RespondTo.env = {'HTTP_ACCEPT' => 'text/html'}
    Rack::RespondTo.mime_type = 'text/plain'
    assert_equal 'text/plain', Rack::RespondTo.mime_type
  end

  ## respond_to

  test "respond_to returns block for requested format" do
    Rack::RespondTo.mime_type = 'application/xml'
    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal 'xml', body
  end

  test "respond_to with no matching format" do
    Rack::RespondTo.mime_type = 'text/html'
    body = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal nil, body
  end

  test "respond_to handles synonymous formats" do
    Rack::RespondTo.mime_type = 'text/html'

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
end
