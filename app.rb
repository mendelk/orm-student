require_relative 'orm'
require_relative 'persistable'
require_relative 'findable'

# require 'pry'

class Student

  DB = SQLite3::Database.new 'students_database.db'

  SCHEMA = {
    id: 'INTEGER PRIMARY KEY',
    name: 'VARCHAR(255)',
    url: 'VARCHAR(255)',
    twitter: 'VARCHAR(255)',
    quote: 'TEXT',
    linkedin: 'TEXT'
  }

  include Persistable
  include Findable

  attr_accessor :name, :tagline, :bio
  attr_reader :id
  attr_finder :name, :tagline, :bio

end

require 'sinatra/base'

module StudentSite
  class App < Sinatra::Base
    get '/' do
      "hello world!"
    end

    get '/students' do
      @students = Student.all
      erb :'students/index'
    end

    get '/students/:id' do |id|
      @student = Student.find(id)
      erb :'students/show'
    end

  end
end

# pry.bindings
