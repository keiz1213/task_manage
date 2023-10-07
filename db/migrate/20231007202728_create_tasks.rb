class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.string :description
      t.integer :priority, null: false
      t.datetime :deadline, null: false
      t.integer :state, null: false

      t.timestamps
    end
  end
end
