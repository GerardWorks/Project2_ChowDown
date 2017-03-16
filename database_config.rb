require 'active_record'

options = {
  adapter: 'postgresql',
  database: 'chowdown'
}

ActiveRecord::Base.establish_connection( ENV['DATABASE_URL'] || options)
