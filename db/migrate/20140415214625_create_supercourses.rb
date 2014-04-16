class CreateSupercourses < ActiveRecord::Migration
  def change
    create_table :supercourses do |t|
      t.string :name
      t.string :title
      
      t.timestamps
    end
    
    change_table :courses do |t|
      t.remove :name
      t.remove :title
      t.integer :supercourse_id
    end
  end
end
