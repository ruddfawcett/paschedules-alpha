class AddExtraFieldsToStudents < ActiveRecord::Migration
  def change
    add_column :students, :class, :string
    add_column :students, :cluster, :string
  end
end
