require 'test/test_helper'

class App
  include Rack::RespondTo
end

class TestRespondTo < Test::Unit::TestCase

  def setup
    Rack::RespondTo.format = nil
  end

  ## api

  test "format accessor" do
    Rack::RespondTo.format = 'xml'
  end

  test "env accessor" do
    Rack::RespondTo.env = {}
  end

  test "mixin injects respond_to class method" do
    assert App.respond_to?(:respond_to)
  end

  test "mixin injects respond_to instance method" do
    assert App.new.respond_to?(:respond_to)
  end

  ## format

  test "format is extracted from env" do
    Rack::RespondTo.env = {'request.format' => 'xml'}
    assert_equal 'xml', Rack::RespondTo.format
  end

  test "explicitly specified format takes precedence of env's" do
    Rack::RespondTo.env = {'request.format' => 'xml'}
    Rack::RespondTo.format = 'html'
    assert_equal 'html', Rack::RespondTo.format
  end

  test "format is normalized" do
    Rack::RespondTo.format = '.html'
    assert_equal 'html', Rack::RespondTo.format

    Rack::RespondTo.format = :html
    assert_equal 'html', Rack::RespondTo.format

    Rack::RespondTo.format = ' html '
    assert_equal 'html', Rack::RespondTo.format

    Rack::RespondTo.format = 'HTML'
    assert_equal 'html', Rack::RespondTo.format
  end

  ## respond_to

  test "respond_to returns block for requested format" do
    Rack::RespondTo.format = 'xml'
    response = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal 'xml', response
  end

  test "respond_to returns nil when no format matches" do
    Rack::RespondTo.format = 'html'
    response = App.respond_to do |format|
      format.xml { 'xml' }
      format.txt { 'txt' }
    end
    assert_equal nil, response
  end

  test "respond_to handles synonymous formats" do
    Rack::RespondTo.format = 'htm' # htm should trigger both htm and html
    response = App.respond_to do |format|
      format.html { 'html' }
      format.json { 'json' }
    end
    assert_equal 'html', response
  end
end
