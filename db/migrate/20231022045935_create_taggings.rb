class CreateTaggings < ActiveRecord::Migration[7.0]
  def change
    create_table :taggings do |t|
      t.references :task, foreign_key: true
      t.references :tag, foreign_key: true

      t.timestamps
    end
    add_index :taggings, [:task_id, :tag_id], unique: true
  end
end
