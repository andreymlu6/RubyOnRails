class AddUrlToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :url, :string
  end
end
