class AddRawAndCredentialsToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :raw, :string
    add_column :authentications, :credentials, :string
  end
end
