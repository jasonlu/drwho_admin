class CreateTries < ActiveRecord::Migration
  def change
    create_table :tries, :id => false do |t|

      t.string :id, :primary => true
      t.integer :user_id
      t.integer :study_id
      t.integer :course_id
      t.integer :day
      t.integer :stage
      t.integer :phase
      t.float :score

      t.timestamps
    end
    execute "ALTER TABLE tries ADD PRIMARY KEY (id);"
  end
end
