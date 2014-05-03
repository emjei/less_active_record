require_relative 'less_active_record'

class User < LessActiveRecord
  attr_accessor :first_name, :last_name

  # OBLIGATORY method for all the LessActiveRecord classes
  def valid?
    name_is_long_enough?
  end

  # OBLIGATORY method for all the LessActiveRecord classes
  def attribute_names
    [ :first_name, :last_name ]
  end

  # One of the object's usual methods
  def full_name
    "#{ first_name } #{ last_name }"
  end

  private

  # One of the validations
  def name_is_long_enough?
    full_name.length > 8
  end
end
