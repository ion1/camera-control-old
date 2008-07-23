require 'active_record'
require 'fileutils'

require 'cc/logger'

config_root     = File.expand_path '~/.config/camera-control'
database_path   = config_root+'/db.sqlite3'
schema_path     = config_root+'/db.schema.rb'
migrations_path = File.dirname(__FILE__) + '/migrations'

FileUtils.mkdir_p config_root

ActiveRecord::Base.logger = CC::Logger.singleton

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

