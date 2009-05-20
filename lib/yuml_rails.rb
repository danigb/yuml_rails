
module Yuml
  class Dumper #:nodoc:
    private_class_method :new


    def self.dump(stream=STDOUT)
      new.dump(stream)
      stream
    end

    def dump(stream)
      header(stream)
      models(stream)
      bottom(stream)
    end

    private

    def models(stream)
      Dir.new("#{RAILS_ROOT}/app/models").entries.each do |file|
        puts file
      end
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
end