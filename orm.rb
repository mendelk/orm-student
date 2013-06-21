require 'sqlite3'
require 'active_support/inflector'

module ORM

  module ClassMethods

    def db
      self::DB
    end

    def table_name
        self.to_s.downcase.pluralize
    end

    def drop
      db.execute "DROP TABLE IF EXISTS #{table_name}"
    end

    def schema_to_sql
      self::SCHEMA.inject(''){|result, k_v_arr| result << k_v_arr.first.to_s << ' ' << k_v_arr.last << ','}[0..-2]
    end

    def create_table
      db.execute "CREATE TABLE IF NOT EXISTS #{table_name} (#{schema_to_sql})"
    end

    def table_exists?(table)
      !!db.get_first_row("SELECT name FROM sqlite_master WHERE type='table' and name=?", table_name)
    end

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

    def convert_keys(keys, separator = ' AND ')
      keys.map{|key| "#{key} = :#{key}"}.join(separator)
    end

    def attr_finder(*attrs)
      attrs.each do |attr|
        define_singleton_method("find_by_#{attr}") do |attr_val|
          find_single_by_prop(attr.to_s,attr_val)
        end
      end
    end

  end

  module InstanceMethods

    def save
      instance_variable_get("@id") ? update : insert
    end

    def insert
      hash = to_hash
      cols, cols_as_sym = [hash.keys.join(','),hash.keys.collect{|key| ':' << key.to_s}.join(',')]
      db.execute("INSERT INTO #{table_name} (#{cols}) VALUES (#{cols_as_sym})", hash)
      instance_variable_set(:@id, db.last_insert_row_id)
      self
    end

    def update
      hash = to_hash
      db.execute("UPDATE #{table_name} SET #{self.class.convert_keys(hash.keys - [:id],' , ')} WHERE id = :id", hash)
      self
    end

    def to_hash
      hash = {}
      self.class::SCHEMA.keys.each do |prop|
        hash[prop] = self.instance_variable_get("@#{prop}") # if self.instance_variable_get("@#{prop}")
      end
      hash
    end

    def from_hash(hash)
      hash.each do |prop, val|
        self.instance_variable_set("@#{prop}".to_sym, val)
      end
      self
    end

    private

    def db
      self.class.db
    end

    def table_name
      self.class.table_name
    end

  end

end