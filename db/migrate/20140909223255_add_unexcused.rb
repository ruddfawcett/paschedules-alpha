class AddUnexcused < ActiveRecord::Migration
  def change
    add_column :people, :unexcused, :integer
  end
end
