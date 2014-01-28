class ChangeTypeOfNameInSections < ActiveRecord::Migration
  def change
    change_column :sections, :name, :string
  end
end
