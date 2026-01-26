File.rm_rf!("./todo-persist/jane")
File.rm_rf!("./todo-persist/john")
File.mkdir_p!("./todo-persist")
ExUnit.start()
