ActiveAdmin.register User do
  permit_params :email, :encrypted_password, :password, :first_name, :last_name, :full_phone_number, :gender, :role, :date_of_birth, :country, :city, :state, :address, :jti, :stripe_customer_id

  member_action :download_csv, method: :get do
    user = User.find(params[:id])
    send_data user.to_csv, filename: "user_#{user.id}.csv"
  end

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    actions defaults: true do |user|
      link_to 'Download', download_csv_admin_user_path(user), method: :get
    end
  end
end
