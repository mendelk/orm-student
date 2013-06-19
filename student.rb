require_relative 'orm'

class Student
  extend ORM
  puts self.to_s.downcase
end

