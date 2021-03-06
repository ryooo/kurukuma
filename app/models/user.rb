class User
  include Mongoid::Document
  field :provider, type: String
  field :uid, type: String
  field :info, type: Hash
  field :token, type: String
  field :secret, type: String

  def self.find_by_provider_and_uid(provider, uid)
    user = User.where(:provider => provider.to_s, :uid => uid.to_s).first
    return user
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.info = auth['info']
      user.token = auth.credentials['token']
      user.secret = auth.credentials['secret']
    end
  end
end
