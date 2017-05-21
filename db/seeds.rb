# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

  [
    'Lucille',
    'Mimi',
    'Standford',
    'Doyle'
  ].each do |name|
    User.create! email: "#{name}@example.ai", is_ai: true, password: SecureRandom.base64
  end
