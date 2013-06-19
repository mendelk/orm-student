require 'sqlite3'


module ORM
  DB = SQLite3::Database.new 'screwy.db'
  
  def drop
    DB.execute ("DROP TABLE IF EXISTS ? ", self.to_s.downcase)
  end

  def create_table
    DB.execute "CREATE TABLE IF NOT EXISTS ? (id INT PRIMARY KEY)", self.to_s.downcase

  end
end