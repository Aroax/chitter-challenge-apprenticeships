require 'bcrypt'
require_relative 'database_connection'

class User
  attr_reader :username, :id


  def self.add(username:, password:)
    encrypted_password = BCrypt::Password.create(password)
    new_user = DatabaseConnection.query(sql: "INSERT INTO users (username, password) VALUES($1, $2) RETURNING id, username, password;", params: [username, encrypted_password])
    User.new(
      username: new_user[0]['username'],
      password: new_user[0]['password'],
      id: new_user[0]['id'],
    )
  end

  def self.all
    users = DatabaseConnection.query(sql: 'SELECT * FROM users;', params: [])
    users.map do |user|
      User.new(
        username: user['username'],
        password: user['password'],
        id: user['id'],
      )
    end
  end

  def self.authenticate(username:, password:)
    result = DatabaseConnection.query(sql: "SELECT * FROM users WHERE username = $1;", params: [username])
    # check for existing username in database => return if no match
    return unless result.any?
    # user exists, so now check password correct else return
    return unless BCrypt::Password.new(result[0]['password']) == password
    # return the user for test assessments
    User.new(
      username: result[0]['username'],
      password: result[0]['password'],
      id: result[0]['id'],
    )
  end

  def initialize(username:, password:, id:)
    @username = username
    @password = password
    @id = id
  end


end
