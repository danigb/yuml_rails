
module YUML
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


    def model(file, dir)
      file = File.new(File.join(dir, file))

    end




    def camelize(name)
      name.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
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

  class Parser
    attr_accessor :diagram
    def initialize(diagram=ClassDiagram.new)
      @diagram = diagram
    end

    CLASS_MATCHER = /^\s*class ([a-zA-Z_-]+)\s*(<\s*([a-zA-Z:_]+)\s*)?$/
    BELONGS_TO_MATCHER = /^\s*belongs_to :?([a-z_]+)/
    HAS_ONE_MATCHER = /^\s*belongs_to :?([a-z_]+)/
    def parse(lines)
      current_model = nil
      lines.each do |line|
        if line =~ CLASS_MATCHER
          current_model = add_class($1, $2)
        end
        add_relation(:belongs_to, current_model, $1) if line =~ BELONGS_TO_MATCHER
        add_relation(:has_one, current_model, $1) if line =~ HAS_ONE_MATCHER
      end
    end

    def add_class(model_name, parent_name)
      model = @diagram.model(model_name)
      if parent_name
        parent = @diagram.model(parent_name)
        model.parent(parent)
      end
      model
    end

    def add_relation(relation, model, other_name)
      other = @diagram.model(camelize(other_name))
      model.send(relation, other)
    end
  end

  class ClassDiagram
    attr_accessor :models

    def initialize
      @models = {}
    end

    def model(name)
      name = name.to_s
      unless @models[name]
        @models[name] = ClassModel.new(name)
        puts "Add class #{name}"
      end
      @models[name]
    end

    def [](name)
      @models[name.to_s]
    end

    def size
      @models.size
    end
  end

  class ClassModel
    attr_accessor :name
    attr_accessor :relations
    
    def initialize(name)
      @name = name
      @relations = []
    end

    def parent(parent)
      @relations << Relation.new(self, parent, Relation::Inheritance)
    end

    def belongs_to(other)
      @relations << Relation.new(self, other, Relation::Directional)
    end

    def has_one(other)
      @relations << Relation.new(other, self, Relation::Directional)
    end

    def to_s
      @name
    end
  end

  class Relation
    Inheritance = '^'
    Directional = '->'
    
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