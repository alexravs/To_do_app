require('pg')
DB = PG.connect({:dbname => 'to_do'})

require_relative("task")


class List
  attr_reader(:name, :id)
  
  define_method(:initialize) do |id, name, user_id|
    @name = name
    
    @id = id
    
      
    @user_id = user_id
  end
  
  define_method(:save) do
    request_save = DB.exec("INSERT INTO lists (name, user_id) VALUES('#{@name}', #{@user_id}) RETURNING id;")
    @id = request_save.first().fetch("id").to_i()
  end
  
  define_method(:delete) do
    DB.exec("DELETE FROM lists WHERE id = #{@id};")
  end

  define_singleton_method(:all_lists) do
    returned_all_lists = []
    request_all = ("SELECT * FROM lists;")
    all_lists_from_db = DB.exec(request_all)
    all_lists_from_db.each() do |list|
      id = list.fetch("id").to_i()
      name = list.fetch("name")
      returned_all_lists.push(List.new(name, id))
    end
    returned_all_lists
  end
  
  define_singleton_method(:find) do |id|
    returned_list = nil
    request_find = ("SELECT * FROM lists WHERE id = #{id};")
    returned_list = DB.exec(request_find)
    id = returned_list.first().fetch("id")
    name = returned_list.first().fetch("name")
    List.new(id, name, nil)
  end
  
  
  define_method(:tasks) do
    returned_tasks = []
    request_tasks = ("SELECT * FROM tasks WHERE list_id = #{@id} order by date asc;;")
    all_tasks_from_db = DB.exec(request_tasks)
    all_tasks_from_db.each() do |task|
      list_id = task.fetch("list_id")
      description = task.fetch("description")
      id = task.fetch("id")
      date = task.fetch("date")
      puts description
      returned_tasks.push(Task.new(description, list_id, id, date))
    end
    returned_tasks
  end
end

#test = List.find(2)
#puts test.name()
#tache = test.tasks 
#tache.each() do |task|
  #puts task.description()
#end
