require('pg')
DB = PG.connect({:dbname => 'to_do'})

class User
  
  attr_reader(:user_name, :password, :avatar, :id)
  
  define_method(:initialize) do |user_name, password, user_id|
    @user_name = user_name
    @password = password
    @avatar = nil
    if defined?(user_id)
      @id = user_id
    else
      @id = nil
    end
  end
  
  define_method(:save) do
    request_save = DB.exec("INSERT INTO users (user_name, password, avatar) VALUES('#{@user_name}', '#{@password}', '#{@avatar}') RETURNING id;")
    @id = request_save.first().fetch("id").to_i()

  end
  
  define_singleton_method(:is_in_database?) do |username, password|
    request_save = DB.exec("SELECT id, user_name, avatar FROM users WHERE user_name = '#{username}' AND password = '#{password}';")
    
    result = request_save.first()
    
  end
  
  define_method(:lists) do
    returned_lists = []
    request_lists = ("SELECT * FROM lists WHERE user_id = #{@id};")
    
    all_lists_from_db = DB.exec(request_lists)
    all_lists_from_db.each() do |list|
      id = list.fetch("id")
      name = list.fetch("name")
      user_id = list.fetch("user_id")
      
      returned_lists.push(List.new(id, name, user_id))
    end
    returned_lists
  end
  
  define_method(:setAvatar) do |file_name|
    @avatar = file_name
    #request_avatar= DB.exec("INSERT INTO users (avatar) VALUES ('#{file_name}') RETURNING id;")
  end
  
  define_singleton_method(:find) do |id|
    returned_user = nil
    request_find = ("SELECT * FROM users WHERE id = #{id};")
    returned_user = DB.exec(request_find)
    password = returned_user.first().fetch("password")
    username = returned_user.first().fetch("user_name")
    User.new(username, password, id)
  end
end


