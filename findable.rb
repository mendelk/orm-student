module Findable

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def find_single_by_prop(prop,val)
      res = db.execute2 "SELECT * FROM #{table_name} WHERE #{prop}=? LIMIT 1", val
      self.new.from_hash(Hash[res.transpose])
    end

    def find(id)
      find_single_by_prop("id",id)
    end

    def where(hash)
      return [] if hash.empty?
      results = []
      headers = nil
      db.execute2 "SELECT * FROM #{table_name} WHERE #{convert_keys(hash.keys)}", hash do |row|
        results << self.new.from_hash(Hash[[headers,row].transpose]) if headers
        headers ||= row
      end
      results
    end

    def all
      results = []
      headers = nil
      db.execute2 "SELECT * FROM #{table_name}" do |row|
        results << self.new.from_hash(Hash[[headers,row].transpose]) if headers
        headers ||= row
      end
      results
    end

    def attr_finder(*attrs)
      attrs.each do |attr|
        define_singleton_method("find_by_#{attr}") do |attr_val|
          find_single_by_prop(attr.to_s,attr_val)
        end
      end
    end

  end

end