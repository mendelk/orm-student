require_relative 'orm'
# require 'pry'

class Student

  DB = SQLite3::Database.new 'screwy.db'

  SCHEMA = {
    id: 'INTEGER PRIMARY KEY',
    name: 'VARCHAR(255)',
    tagline: 'TEXT',
    bio: 'TEXT'
  }

  extend ORM::ClassMethods
  include ORM::InstanceMethods

  attr_accessor :name, :tagline, :bio
  attr_reader :id
  attr_finder :name, :tagline, :bio

  def initialize
    add_to_collection
  end

end

# pry.bindings
