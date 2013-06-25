require 'sqlite3'

class Sqlite3_ORM

  attr_reader :db

  def initialize(table_name)
    @db = SQLite3::Database.new table_name
  end

end