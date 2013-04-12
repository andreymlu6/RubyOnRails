class AddTitleToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :title, :string
  end
end
