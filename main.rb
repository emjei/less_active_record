require_relative 'user'

# Init database
User.load

# Work!
p User.all
valid_user_1 = User.create(first_name: 'Johny', last_name: 'Boy')
valid_user_2 = User.new(first_name: 'Thomas', last_name: 'Boy')
valid_user_2.save!

p User.find(1)
p User.find(2).attributes
p User.find(1).copy

p User.find(2).update!(first_name: 'Lawrence')
p User.all

invalid_user = User.create(first_name: '')
p User.all

valid_user_1.destroy
valid_user_2.destroy
p User.all

# Close database
User.dump
