require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/yuml_rails.rb')
require 'rubygems'
require 'shoulda'

class ParserTest < Test::Unit::TestCase
  context "A Parser instance" do
    setup do
      @diagram = YUML::ClassDiagram.new()
      @parser = YUML::Parser.new(@diagram)
    end

    should "have a diagram" do
      assert @parser.diagram
    end

    should "parse class with no parent" do
      file = "class Simple\nend"
    
      @parser.parse(file)
      assert_equal 1, @diagram.size
      assert @diagram[:Simple]
    end

    should "parse class with parent" do
      file = "class Simple < MyModule::TheClass\nend"
      @parser.parse(file)
      assert_equal 2, @diagram.size
      assert @diagram[:Simple]
      assert @diagram['MyModule::TheClass']
    end
  end
end