import Config

# config_env() will return one of :test, :dev, :prod

http_port = System.get_env("TODO_HTTP_PORT", "5454")
config :todo, http_port: String.to_integer(http_port)

db_dir = System.get_env("TODO_DB_DIR", "./todo-persist")
config :todo, db_dir: db_dir

db_pool_size = System.get_env("TODO_DB_POOL_SIZE", "3")
config :todo, db_pool_size: String.to_integer(db_pool_size)
