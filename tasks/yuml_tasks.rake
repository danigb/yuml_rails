# desc "Explaining what the task does" task :yuml do
#   # Task goes here
# end

task :yuml  do
  require File.join(File.dirname(__FILE__), '../lib/yuml_rails.rb')
  File.open(File.join(RAILS_ROOT, 'doc/yuml.html'), 'w') do |file|
    Yuml::Dumper.dump(file)
  end
  puts "YUML html page created as doc/yuml.html"
end


namespace :uml do
  desc "Generate an XMI db/schema.xml file describing the current DB as seen by AR. Produces XMI 1.1 for UML 1.3 Rose Extended, viewable e.g. by StarUML"
  task :schema => :environment do
    require File.join(File.dirname(__FILE__), '../lib/uml_dumper.rb')
    File.open("db/schema.xml", "w") do |file|
      ActiveRecord::UmlDumper.dump(ActiveRecord::Base.connection, file)
    end
    puts "Done. Schema XMI created as db/schema.xml."
  end
end
