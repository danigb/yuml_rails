
class Test::Unit::TestCase
  def self.should_have_relation(relation)
    klass = self.name.gsub(/Test$/, '').constantize

    context "#{klass}" do
      should "have relation type #{relation}" do
        
      end
    end
  end
end
