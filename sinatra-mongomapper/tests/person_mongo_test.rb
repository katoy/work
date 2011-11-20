# conding: utf-8
require File.expand_path('test_helper', File.dirname(__FILE__))
require 'pp'

class PersonTest < Test::Unit::TestCase
  TARO = {
    'name' => "山田太郎",
    'address' => "東京都千代田区1丁目1番地",
    'tel' => "03-1234-5678",
    'birthday' => "1970-01-01",
    'gender' => Person::MALE
  }
  TAROX = {
    'name' => "山田太郎X",
    'address' => "東京都千代田区1丁目1番地",
    'tel' => "03-1234-5678",
    'birthday' => "1970-01-01",
    'gender' => Person::MALE
  }
  
  def setup
    MongoMapper.database.collections.each {|collection| collection.remove}
  end
  
  def test_initialize
    person = Person.new(TARO)
    assert_not_nil(person)
    assert_equal(TARO['name'], person.name)
    assert_equal(TARO['address'], person.address)
    assert_equal(TARO['tel'], person.tel)
    assert_equal(TARO['birthday'], person.birthday)
    assert_equal(TARO['gender'], person.gender)
    assert_equal(nil, person.db_id)
  end
  
  def test_to_yaml
    taro = Person.new(TARO)
    yaml = taro.to_yaml
    taro_copy = YAML.load(yaml)
    assert_equal("山田太郎", taro_copy['name'])
  end
  
  def test_save
    taro = Person.new(TARO)
    assert(taro.save())
    assert_nil(taro.error_messages)
    assert(taro.db_id != nil)
    
    assert(!taro.save())
    assert_not_nil(taro.error_messages)
    assert(taro.db_id != nil)
  end
  
  def test_delete
    tarox = Person.new(TAROX)
    tarox.save()
    tarox.delete()
    assert(tarox.db_id == nil)
  end
  
  def test_save_with_validation
    taro = Person.new
    assert !taro.save()
    assert_not_nil(taro.error_messages)
  end
  
  def test_find_by_keyword

    taro = Person.new(TARO)
    taro.save
    hanako = Person.new(TARO.merge({ 'name' => '鈴木花子' }))
    hanako.save
    
    results = Person.find_by_keyword("東京都")
    assert_equal(2, results.size)
    
    results = Person.find_by_keyword("太郎")
    assert_equal(1, results.size)
    assert_equal("山田太郎", results.first.name)
    
    results = Person.find_by_keyword("鈴木")
    assert_equal(1, results.size)
    assert_equal("鈴木花子", results.first.name)
  end
end