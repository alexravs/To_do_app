require('pg')
DB = PG.connect({:dbname => 'to_do'})


require('sinatra')
require('sinatra/reloader')
require("./lib/task")
require("./lib/list")
require("./lib/user")
enable :sessions


#set :bind, '0.0.0.0'

get("/") do

  if session[:connected]
    
    id_de_user = session.fetch(:user_id)
    puts id_de_user
    @current_user = User.find(id_de_user)
    
    @lists = @current_user.lists()
    
    
    
  end
  erb(:index)
end

post("/lists") do 
  name_list = params.fetch("name")
  new_list = List.new(nil,name_list, session[:user_id])
  new_list.save()
  @current_user = User.find(session[:user_id])
  @lists = @current_user.lists()
  
  erb(:index)
end

get("/list/:id") do
  @id = params.fetch("id")

  @current_list = List.find(@id)
  #puts @current_list.class()
  @tasks = @current_list.tasks()
  #puts @current_list.id()
  erb(:list)
end

post("/tasks") do
  @id = params.fetch("id")
  @current_list = List.find(@id)
  puts @current_list.class()
  description = params.fetch("description")
  task = Task.new(description, @id, nil)
  task.save()
  @tasks = @current_list.tasks()
  erb(:list)
end

post("/list/edit_task") do
  @id = params.fetch("id")
  @current_list = List.find(@id)
  @tasks = @current_list.tasks()
  new_description = params["new_description"]
  task_id = params["task_id"]
  task_to_be_modified = Task.find(task_id)
  task_to_be_modified.set_description(new_description)
  erb(:list)
end

get("/sign_up") do
  erb(:sign_up)
end

get("/sign_up") do
  erb(:sign_in)
end

post("/sign_up") do
  
  
  username = params.fetch("username")
  password = params.fetch("password")
  @new_user = User.new(username,password,nil)
  
  if params['myfile'].nil?().!()
    File.open('public/img/' + params['myfile'][:filename], "w") do |f|
      f.write(params['myfile'][:tempfile].read)
    end
    img_avatar = params['myfile'][:filename]
    @new_user.setAvatar(img_avatar) 
  end
  
  
  @new_user.save()
  session[:connected] = true;
  session[:user_id] = @new_user.id()
  session[:name] = @new_user.user_name()
  if params['myfile'].nil?().!()
    session[:avatar] = @new_user.avatar()
  end
  @lists = @new_user.lists()
  redirect '/'
  
end

get("/log_out") do
  session.clear
  redirect '/'
end

get("/delete_list/:id") do
  @id = params.fetch("id")
  @list_to_be_deleted = List.find(@id)
  @list_to_be_deleted.delete()
  Task.clear(@id)
  redirect("/")
  
end

post("/sign_in") do
  username = params.fetch("username")
  password = params.fetch("password")
  user_to_connect = User.is_in_database?(username, password)
  if user_to_connect.nil?().!()
    session[:connected] = true;
    session[:user_id] = user_to_connect.fetch("id").to_i()
    session[:name] = user_to_connect.fetch("user_name")
    session[:avatar] = user_to_connect.fetch("avatar")
  end
  redirect '/'
end

get("/upload") do
  erb(:upload)
end

get("/delete_task/:id_task_to_delete/:id_current_list") do
  @id_task_to_delete = params.fetch("id_task_to_delete")
  @task_to_be_deleted = Task.find(@id_task_to_delete)
  @task_to_be_deleted.delete()
  @id = params.fetch("id_current_list")
  @current_list = List.find(@id)
  @tasks = @current_list.tasks()
  erb(:list)
end


post("/tasks_clear") do
   
  @id = params.fetch("id")

  #new_param = {"id" => @id}
  #params = params.merge(new_param)
  
  #puts "aurevoir"
  Task.clear(@id)
  redirect '/'
end