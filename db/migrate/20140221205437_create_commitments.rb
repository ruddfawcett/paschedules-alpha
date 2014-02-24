class CreateCommitments < ActiveRecord::Migration
  def change
    create_table :commitments do |t|
      t.string :teacher_name
      t.string :name
      t.string :title

      t.timestamps
    end

    create_table :students_commitments do |t|
      t.integer :student_id
      t.integer :commitment_id
    end
  end
end
