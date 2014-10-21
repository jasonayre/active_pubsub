require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "spec/test.db"
)

ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.drop_table(table)
end

ActiveRecord::Schema.define(:version => 1) do
  create_table :posts do |t|
    t.string :body
    t.string :title
    t.string :slug
    t.integer :author_id

    t.timestamps
  end

  create_table :author_post_reports do |t|
    t.integer :author_id
    t.integer :post_count
  end

  create_table :authors do |t|
    t.string :first_name
    t.string :last_name
    t.string :slug

    t.timestamps
  end
end
