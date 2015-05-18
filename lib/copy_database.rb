require_relative '../config/database'

class CopyDatabase
  def self.copy(source, destination, options = {})
    reset = options.fetch(:reset, true)

    puts "Cloning #{source} to #{destination}"
    puts `mysql -e 'DROP DATABASE #{destination}'` if reset
    puts `mysql -e 'CREATE DATABASE #{destination}'` if reset
    puts `mysqldump --single-transaction --tz-utc=false #{source} | mysql -uroot #{destination}`

    DB.connect(destination)
  end
end
