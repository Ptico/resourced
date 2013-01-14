def setup_db
  FileUtils.rm("test.sqlite3") if File.exists?("test.sqlite3")

  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "test.sqlite3")

  ActiveRecord::Schema.define do
    create_table :users, :force => true do |t|
      t.string :name
      t.string :email
      t.string :role
    end
  end
end

def teardown_db
  FileUtils.rm("test.sqlite3") if File.exists?("test.sqlite3")
end

def add_user(id, name, email, role)
  ActiveRecord::Base.connection.execute("INSERT INTO users (id, name, email, role) VALUES (#{id}, '#{name}', '#{email}', '#{role}')")
end