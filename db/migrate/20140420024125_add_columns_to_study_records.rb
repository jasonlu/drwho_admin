class AddColumnsToStudyRecords < ActiveRecord::Migration
  def change
    add_column :study_records, :wrong, :bool
  end
end
