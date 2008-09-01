# camera-control – Control Sanyo PTZ cameras with a custom input board
# Copyright © 2008 Johan Kiviniemi
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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

