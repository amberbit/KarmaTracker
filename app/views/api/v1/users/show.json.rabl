object @user

attributes :id, :email

node(:token, if: lambda { |user| user.api_key }) { |user| user.api_key.token }
node(:admin, if: lambda { |user| user.api_key && @current_admin.present? }) { |user| user.api_key.admin }
node(:errors, unless: lambda { |user| user.valid? } ) { |user| user.errors.messages }
