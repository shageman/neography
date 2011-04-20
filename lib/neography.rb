def find_and_require_user_defined_code
  extensions_path = ENV['neography_extensions'] || "~/.neography"
  extensions_path = File.expand_path(extensions_path)
  if File.exists?(extensions_path)
    Dir.open extensions_path do |dir|
      dir.entries.each do |file|
        if file.split('.').size > 1 && file.split('.').last == 'rb'
          extension = File.join(File.expand_path(extensions_path), file)
          require(extension) && puts("Loaded Extension: #{extension}")
        end
      end
    end
  else
    puts "No Extensions Found: #{extensions_path}"
  end
end

DIRECTIONS = ["incoming", "in", "outgoing", "out", "all", "both"]

require 'typhoeus'
require 'json'
require 'logger'
require 'ostruct'

require File.expand_path(File.join(File.dirname(__FILE__), 'ext/object'))

require File.expand_path(File.join(File.dirname(__FILE__), 'neography/config'))
require File.expand_path(File.join(File.dirname(__FILE__), 'neography/rest'))
require File.expand_path(File.join(File.dirname(__FILE__), 'neography/neography'))

require File.expand_path(File.join(File.dirname(__FILE__), 'neography/property_container'))
require File.expand_path(File.join(File.dirname(__FILE__), 'neography/property'))
require File.expand_path(File.join(File.dirname(__FILE__), 'neography/node_relationship'))
require File.expand_path(File.join(File.dirname(__FILE__), 'neography/node_path'))
require File.expand_path(File.join(File.dirname(__FILE__), 'neography/relationship_traverser'))
require File.expand_path(File.join(File.dirname(__FILE__), 'neography/node_traverser'))
require File.expand_path(File.join(File.dirname(__FILE__), 'neography/path_traverser'))
require File.expand_path(File.join(File.dirname(__FILE__), 'neography/equal'))

require File.expand_path(File.join(File.dirname(__FILE__), 'neography/node'))
require File.expand_path(File.join(File.dirname(__FILE__), 'neography/relationship'))

find_and_require_user_defined_code

