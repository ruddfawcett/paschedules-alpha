class AddDepartmentToPeople < ActiveRecord::Migration
  def change
    add_column :people, :department, :string
  end
end
