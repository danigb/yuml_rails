
module Yuml
  class Dumper #:nodoc:
    private_class_method :new

    CLASS_MATCHER = /^class ([a-zA-Z_-]+)\s*<\s*([a-zA-Z:_]+)\s*$/

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
      @models.sort.each {|m| names << "[#{m}]," }
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
      file.readlines.each do |line|
        if line =~ CLASS_MATCHER
          parent = get_model($2)
          model = get_model($1)
        end
      end
    end


    def get_model(name)
      @models[name] ||= UmlModel.new(name)
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
    
    def initialize(name)
      @name = name
    end

    def to_s
      @name
    end
  end

end