class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :user
      t.belongs_to :status
      t.text :content

      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, :status_id
  end
end
