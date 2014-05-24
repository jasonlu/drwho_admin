class AddColumnsToStudyRecords2 < ActiveRecord::Migration
  def change
    add_column :study_records, :group_id, :string
  end
end
