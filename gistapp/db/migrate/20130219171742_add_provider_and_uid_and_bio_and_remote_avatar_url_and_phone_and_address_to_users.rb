class AddProviderAndUidAndBioAndRemoteAvatarUrlAndPhoneAndAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uid, :string
    add_column :users, :bio, :string
    add_column :users, :remote_avatar_url, :string
    add_column :users, :phone, :string
    add_column :users, :address, :string
    add_column :users, :confirmed_at, :timestamp
  end
end
