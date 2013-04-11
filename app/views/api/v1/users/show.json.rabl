object @user
attributes :id, :email
node(:token) { @user.api_key.token }
