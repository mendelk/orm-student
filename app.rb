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

  attr_accessor :name, :twitter, :quote, :linkedin
  attr_reader :id
  attr_finder :name, :twitter, :quote, :linkedin

end

require 'sinatra/base'

module StudentSite
  class App < Sinatra::Base
    get '/' do
      redirect '/students'
    end

    get '/students' do
      @students = Student.all
      erb :'students/index'
    end

    get '/students/new' do
      erb :'students/new'
    end

    get '/students/:id' do |id|
      @student = Student.find(id)
      erb :'students/show'
    end

    get '/students/:id/edit' do |id|
      @student = Student.find(id)
      erb :'students/edit'
    end

    post '/students' do
      student = Student.new
      student.from_hash(params[:student])

      if student.save
        redirect '/students'
      else
        redirect '/students/new'
      end
    end

    put '/students/:id' do |id|
      student = Student.find(id)
      student.from_hash(params[:student])

      if student.save
        redirect "/students/#{id}"
      else
        redirect "/students/#{id}/edit"
      end
    end

    delete '/students/:id' do |id|
      student = Student.find(id)
      student.destroy!
      redirect "/students"
    end

  end
end

# pry.bindings
