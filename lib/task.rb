require('pg')
DB = PG.connect({:dbname => 'to_do'})

class Task
  attr_reader(:description, :list_id, :id, :date)
  attr_writer(:description)

  
  define_method(:initialize) do |description, list_id, id, date|
    @description = description
    @list_id = list_id
    @id = id
    @date = date
  end
  
  define_singleton_method(:find) do |id|
    returned_task = nil
    request_find = ("SELECT * FROM tasks WHERE id = #{id};")
    returned_task = DB.exec(request_find)
    description = returned_task.first().fetch("description")
    id = returned_task.first().fetch("id")
    list_id = returned_task.first().fetch("list_id")
    date = returned_task.first().fetch("date")
    test = Task.new(description, list_id, id, date)
  
    test
  end
  
  define_method(:save) do
    request_save = DB.exec("INSERT INTO tasks (description, list_id, date) VALUES('#{@description}', #{@list_id}, '#{@date}' ) RETURNING id;")
    @id = request_save.first().fetch("id").to_i()
  end
  
  define_method(:delete) do
    DB.exec("DELETE FROM tasks WHERE id = #{@id};")
  end
  
  define_singleton_method(:clear) do |id|
    request_clear = ("DELETE FROM tasks WHERE list_id = #{id};")
    DB.exec(request_clear)
  end
  
  define_singleton_method(:all_tasks) do
    returned_all_tasks = []
    request_all = ("SELECT * FROM tasks;")
    all_task_from_db = DB.exec(request_all)
    all_task_from_db.each() do |task|
      list_id = task.fetch("list_id").to_i()
      description = task.fetch("description")
      date = task.fetch("date")
      returned_all_tasks.push(Task.new(description, list_id, nil, date))
    end
    returned_all_tasks
  end
  
  define_method(:set_description) do |new_description|
    @description = new_description
    
    DB.exec("UPDATE tasks SET description = '#{@description}' WHERE id = #{@id};")
  end

end

 






