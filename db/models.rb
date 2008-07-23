require 'active_record'
require 'fileutils'

require 'cc/logger'
require 'cc/singleton'

data_root       = File.expand_path '~/.local/share/camera-control'
database_path   = data_root+'/db.sqlite3'
schema_path     = data_root+'/db.schema.rb'
migrations_path = File.dirname(__FILE__) + '/migrations'

FileUtils.mkdir_p data_root

ActiveRecord::Base.logger = CC::Logger.singleton CC::Logger::LOG_ROOT+'/db.log'
ActiveRecord::Base.logger.level = Logger::DEBUG

ActiveRecord::Base.establish_connection :adapter  => 'sqlite3',
                                        :database => database_path

# Load models.
Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |file|
  basename = File.basename file, '.rb'
  require "db/models/#{basename}"
end

# Run migrations.
ActiveRecord::Migrator.migrate migrations_path

# Dump schema.
open schema_path, 'w' do |io|
  ActiveRecord::SchemaDumper.dump ActiveRecord::Base.connection, io
end

