require 'active_record'

options = {
  adapter: 'postgresql',
  database: 'feedmefast'
}

ActiveRecord::Base.establish_connection(options)
