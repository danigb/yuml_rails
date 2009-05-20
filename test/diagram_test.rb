require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/yuml_rails.rb')
require 'rubygems'
require 'shoulda'

class DiagramTest < Test::Unit::TestCase
  context "A Diagram instance" do
    setup do
      @diagram = YUML::ClassDiagram.new
    end

    should "know the number of models" do
      assert_equal 0, @diagram.size
    end

    should "create a model instance if not exist" do
      assert_equal 0, @diagram.size
      model = @diagram.model("Simple")
      assert_equal 1, @diagram.size
      assert model
      assert YUML::ClassModel, model.class
    end

    should "retrieve a model if exists" do
      assert_nil @diagram[:Simple]
      @diagram.model(:Simple)
      assert @diagram['Simple']
    end



  end
end