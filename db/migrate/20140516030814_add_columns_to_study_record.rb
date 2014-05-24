class AddColumnsToStudyRecord < ActiveRecord::Migration
  def change
    add_column :study_records, :try_id, :string
  end
end
