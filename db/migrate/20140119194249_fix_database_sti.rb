class FixDatabaseSti < ActiveRecord::Migration
  def change
    drop_table :students
    drop_table :teachers
    add_column :people, :cluster, :string
    add_column :people, :grad_year, :string
  end
end
