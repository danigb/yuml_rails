

module YUML
  class Dumper #:nodoc:
    private_class_method :new

    def self.dump(stream=STDOUT)
      parser = Parser.new
      dir = File.join(RAILS_ROOT, '/app/models')
      Dir.foreach(dir) do |name|
        unless name == '.' || name == '..'
          file = File.new(File.join(dir, name))
          parser.parse(file.readlines)
        end
      end
      serializer = YUML::Serializer.new(stream)
      serializer.to_html(parser.diagram)
    end
  end
  
  class Serializer
    def initialize(stream)
      @stream = stream
    end
    
    def to_html(diagram)
      @stream.puts <<HEADER
<html>
  <head><title>YUML rails class diagram</title>
  </head><body>
HEADER

      names = '<img src="http://yuml.me/diagram/class/'
      diagram.each do |model|
        model.relations.each {|r| names << "#{r},"}
      end
      @stream << names.chop
      @stream << '" />'

      @stream.puts <<BOTTOM
</body></html>

BOTTOM
    end
  end

  class Parser
    attr_accessor :diagram
    def initialize(diagram=ClassDiagram.new)
      @diagram = diagram
    end

    CLASS_MATCHER = /^\s*class ([a-zA-Z_-]+)\s*(?:<\s*([a-zA-Z:_]+)\s*)?$/
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


    def camelize(name)
      name.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
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
      end
      @models[name]
    end

    def [](name)
      @models[name.to_s]
    end

    def size
      @models.size
    end

    def each
      @models.each_value {|v| yield v}
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

    attr_accessor :type, :origin, :target


    def initialize(origin, target, type)
      @origin = origin
      @target = target
      @type = type
    end

    def to_s
      "[#{@origin}]#{@type}[#{@target}]"
    end
  end

end