require_relative 'less_active_record'

class User < LessActiveRecord
  attribute :first_name
  attribute :last_name

  validate :name_is_long_enough?

  # One of the object's usual methods
  def full_name
    "#{ first_name } #{ last_name }"
  end

  private

  # One of the validations - usually private
  def name_is_long_enough?
    full_name.length > 8
  end
end
