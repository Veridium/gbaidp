class Connect::Byoi < ActiveRecord::Base
  belongs_to :account

  def userinfo
    OpenIDConnect::ResponseObject::UserInfo.new(
      name:         account.email,
      email:        account.email,
      address:      'Springfield',
      profile:      "http://example.org",
      locale:       'en_US',
      phone_number: '+1 555 555 1212',
      verified: false
    )
  end

  class << self
    def authenticate
      Account.create!(byoi: create!)
    end
  end
end