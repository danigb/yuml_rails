
module Yuml
  class Dumper #:nodoc:
    private_class_method :new

    def self.dump(stream=STDOUT)
      new.dump(stream)
      stream
    end

    def initialize()
      @models = {}
    end

    def dump(stream)
      header(stream)
      models()
      generate(stream)
      bottom(stream)
    end

    private


    def generate(stream)
      names = '<img src="http://yuml.me/diagram/class/'
      @models.keys.sort.each do |name|
        model = @models[name]
        model.relations.each {|r| names << "#{r},"}
      end
      stream << names.chop
      stream << '" />'
    end

    def models()
      dir = File.join(RAILS_ROOT, '/app/models')
      Dir.foreach(dir) do |file|
        model(file, dir) unless file == '.' || file == '..'
      end
    end

    CLASS_MATCHER = /^\s*class ([a-zA-Z_-]+)\s*<\s*([a-zA-Z:_]+)\s*$/
    BELONGS_TO_MATCHER = /^\s*belongs_to :?([a-z_]+)/
    def model(file, dir)
      file = File.new(File.join(dir, file))
      file.readlines.each do |line|
        current_model = add_class($1, $2) if line =~ CLASS_MATCHER
        add_belongs_to(current_model, $1) if line =~ BELONGS_TO_MATCHER
      end
    end
  end

  def add_class(model_name, parent_name)
    parent = get_model(model_name)
    model = get_model(parent_name)
    model.parent(parent)
    model
  end

  def add_belongs_to(model, other)
    puts other
  end


  def get_model(name)
    unless @models[name]
      puts "Adding #{name}"
      @models[name] = UmlModel.new(name)
    end
    @models[name]
  end

  def header(stream)
    stream.puts <<HEADER

<html>
  <head><title>YUML rails class diagram</title>
  </head><body>
HEADER
  end

  def bottom(stream)
    stream.puts <<BOTTOM
</body></html>

BOTTOM
  end

end

class UmlModel
  attr_accessor :name
  attr_accessor :relations
    
  def initialize(name)
    @name = name
    @relations = []
  end

  def parent(parent)
    @relations << Relation.new(self, parent, Relation::Inheritance)
  end

  def to_s
    @name
  end
end

class Relation
  Inheritance = '^'
    
  def initialize(c1, c2, type)
    @c1 = c1
    @c2 = c2
    @symbol = type
  end

  def to_s
    "[#{@c1}]#{@symbol}[#{@c2}]"
  end

  def yuml_type
    case type
    when :inheritance
      '^'
    end
  end
end

end