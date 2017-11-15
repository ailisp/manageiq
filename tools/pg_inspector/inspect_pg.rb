#!/usr/bin/env ruby

## Run pg_inspector using parameters given in local database.yml and v2 key.

# Todo: seems can't find manageiq-gems-pending, MiqPassword
if __FILE__ == $PROGRAM_NAME
  $LOAD_PATH.push(File.expand_path(File.join(__dir__, %w(.. .. lib))))
end

require 'yaml'
require 'manageiq-gems-pending'
require 'util/miq-password'

BASE_DIR = __dir__
DATABASE_YML_FILE_PATH = "#{BASE_DIR}/../../config/database.yml"
V2_KEY_FILE_PATH = "#{BASE_DIR}/../../certs/v2_key"

production_db = YAML.load_file(DATABASE_YML_FILE_PATH)["production"]

db_user = production_db["username"]
db_password_encrypt = production_db["password"]
db_password = MiqPassword.try_decrypt(db_password_encrypt)
db_host = production_db["host"]

# system "#{BASE_DIR}/../pg_inspector.rb -h"
ENV['PGPASSWORD'] = db_password
system("#{BASE_DIR}/../pg_inspector.rb connections -u #{db_user} -s #{db_host} -i")
system("#{BASE_DIR}/../pg_inspector.rb human")
success = system("#{BASE_DIR}/../pg_inspector.rb locks")
if !success
  exit(1)
end
