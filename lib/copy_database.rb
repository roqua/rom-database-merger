require_relative '../config/database'

class CopyDatabase
  def self.copy(source, destination, options = {})
    reset = options.fetch(:reset, true)

    puts "Cloning #{source} to #{destination}"
    puts `mysql -u#{Config[:user]} -p'#{Config[:password]}' -h'#{Config[:host]}' -e 'DROP DATABASE #{destination}'` if reset
    puts `mysql -u#{Config[:user]} -p'#{Config[:password]}' -h'#{Config[:host]}' -e 'CREATE DATABASE #{destination}'` if reset
    puts `mysqldump -u#{Config[:user]} -p'#{Config[:password]}' -h'#{Config[:host]}' --single-transaction --tz-utc=false #{source} | mysql -u#{Config[:user]} -p'#{Config[:password]}' -h'#{Config[:host]}' #{destination}`

    DB.connect(destination)
  end
end
