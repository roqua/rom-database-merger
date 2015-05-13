require 'logger'
require 'sequel'

Config = {user: 'root', password: nil, host: 'localhost',
          source: 'r_demo', target: 'rom_development'}

class DB
  def self.connect(db)
    Sequel.mysql2(host: Config[:host], user: Config[:user], password: Config[:password], database: db,
                  encoding: 'utf8', logger: Logger.new(STDOUT))
  end
end
