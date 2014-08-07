#Less-active Record

Simplified ActiveRecord-like plugin for learning purposes.

## Installation

Add this line to your application's Gemfile:

    gem 'less_active_record'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install less_active_record

## Usage

Create a class which instances you want to persist and subclass `LessActiveRecord`:

```ruby
class User < LessActiveRecord
  # Attributes
  attribute :first_name
  attribute :last_name

  # Validations
  validate :name_is_long_enough?

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
```

Make use of it:

```ruby
# Create a new user record (it will be persisted)
valid_user_1 = User.create(first_name: 'Tom', last_name: 'Sawyer')
valid_user_1.persisted? #=> true

# Build a new user record (it won't be persisted)
valid_user_2 = User.new(first_name: 'Huckleberry', last_name: 'Finn')
valid_user_2.new_record? #=> true

# Persist the newly built record
valid_user_2.save #=> true
valid_user_2.new_record? #=> false

# Retrieve all records
User.all #=> [#<User:0x90375c4 @first_name="Tom", @last_name="Sawyer", @id=1>, #<User:0x9037538 @first_name="Huckleberry", @last_name="Finn", @id=2>]

# Find a user by id
User.find(2) #=> #<User:0x95e721c @first_name="Huckleberry", @last_name="Finn", @id=2>

# Find a user by an attribute
User.where(last_name: 'Sawyer') #=> [#<User:0x8e56f84 @first_name="Tom", @last_name="Sawyer", @id=1>]

# Update attributes
valid_user_1.update(first_name: 'Johny') #=> true
valid_user_2.last_name = 'Finney'
valid_user_2.save #=> true

# Get the attributes
valid_user_1.attributes #=> {:first_name=>"Johny", :last_name=>"Sawyer"}
valid_user_2.attributes #=> {:first_name=>"Huckleberry", :last_name=>"Finney"}

# Destroy unneeded records
valid_user_2.destroy #=> {:first_name=>"Huckleberry", :last_name=>"Finney", :id=>2}

# Persist only valid objects
invalid_user = User.new(first_name: 'Yin', last_name: 'Yang')
invalid_user.valid? #=> false
invalid_user.save #=> false
invalid_user.persisted? #=> false
```

## TODOs

 * Add XML and CSV support
 * Make data file location configurable
 * Redo tests (use more mocks and stubs)
