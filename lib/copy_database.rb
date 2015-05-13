require_relative '../config/database'

class CopyDatabase
  def self.copy(source, destination, reset: true)
    puts "Cloning #{source} to #{destination}"
    puts `mysql -uroot -e 'DROP DATABASE #{destination}'` if reset
    puts `mysql -uroot -e 'CREATE DATABASE #{destination}'` if reset
    puts `mysqldump -uroot #{source} | mysql -uroot #{destination}`

    DB.connect(destination)
  end
end
