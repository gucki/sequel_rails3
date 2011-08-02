require 'sequel_rails3/railtie'

if defined?(Rake)
  Dir[File.join(File.dirname(__FILE__), 'tasks/*.rake')].each{ |file| load(file) }
end

