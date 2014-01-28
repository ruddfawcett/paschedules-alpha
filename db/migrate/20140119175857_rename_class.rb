class RenameClass < ActiveRecord::Migration
  def change
    rename_column :students, :class, :grad_year
  end
end
