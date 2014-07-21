require_relative 'less_active_record'

class User < LessActiveRecord
  attribute :first_name
  attribute :last_name

  # OBLIGATORY method for all the LessActiveRecord classes
  def valid?
    name_is_long_enough?
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
