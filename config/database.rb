require 'logger'
require 'sequel'
require 'dotenv'

Dotenv.load

Config = {
  user: ENV["MYSQL_USER"] || 'root',
  password: ENV["MYSQL_PASSWORD"],
  host: ENV["MYSQL_HOST"] || 'localhost',
  source: ENV.fetch("SOURCE"),
  target: ENV.fetch("TARGET"),
  increment: ENV.fetch("INCREMENT"),
  actually_merge: (ENV["ACTUAL"] == "true" ? true : false)
}

class DB
  def self.connect(db)
    Sequel.mysql2(host: Config[:host], user: Config[:user], password: Config[:password], database: db,
                  encoding: 'utf8', logger: Logger.new(STDOUT))
  end
end
