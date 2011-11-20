# conding: utf-8
require 'rubygems'
require 'yaml'
require 'erb'
require 'mongo_mapper'

mongo_uri = 'mongodb://localhost:27017'
db_name = 'persoon'

MongoMapper.connection = Mongo::Connection.from_uri(mongo_uri)
MongoMapper.database = db_name

class PersonDB
  include MongoMapper::Document

  key :name, String
  key :address, String
  key :tel, String
  key :birthday, String
  key :gender, String

  timestamps!

end

class Person
  MALE = "m"
  FEMALE = "f"
  
  attr_accessor :name, :address, :tel, :birthday, :gender, :db_id, :logs, :error_messages
  
  def initialize(params={})
    self.name = params['name']
    self.address = params['address']
    self.tel = params['tel']
    self.birthday = params['birthday']
    self.gender = params['gender']

    self.db_id = nil
  end

  def self.find_by_keyword(keyword)
    results = []

    reg = Regexp.new(keyword)

    PersonDB.all().each { |ent|
      if (reg =~ ent.name or
            reg =~ ent.address or
            reg =~ ent.tel or
            reg =~ ent.birthday or
            reg =~ ent.gender)

        p = Person.new(
          'name' => ent.name,
          'address' => ent.address,
          'tel' => ent.tel,
          'birthday' => ent.birthday,
          'gender' => ent.gender)
        p.db_id = ent.id
        results << p
      end
    }
    return results
  end

  def to_yaml
    person = self
    erb = ERB.new(TEMPLATE)
    erb.result(binding)
  end
  
  def save()
    unless self.name && self.name.strip != ''
      self.error_messages = ["Name is required."]
      return false
    end

    param = {
      :name => self.name,
      :address => self.address,
      :tel => self.tel,
      :birthday => self.birthday,
      :gender => self.gender
    }
    if (PersonDB.all(param).count > 0)
      self.error_messages = ["登録済みです."]
      return false
    end
    
    persondb = PersonDB.new(param)

    persondb.save!
    self.db_id = persondb.id
    return true
  end
  
  def delete()
    if self.db_id
      PersonDB.find(self.db_id).destroy
    end
    self.db_id = nil
  end
    
  TEMPLATE =<<EOS
name: "<%= person.name %>"
address: "<%= person.address %>"
tel: "<%= person.tel %>"
birthday: "<%= person.birthday %>"
gender: "<%= person.gender %>"
logs:
EOS
end