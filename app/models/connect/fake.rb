class Connect::Fake < ActiveRecord::Base
  belongs_to :account

  def userinfo
    OpenIDConnect::ResponseObject::UserInfo.new(
      name:         'Marge Simpson',
      email:        'marge@example.com',
      address:      'Springfield',
      profile:      'http://example.com/',
      locale:       'en_US',
      phone_number: '+1 555 555 1212',
      verified: false
    )
  end

  class << self
    def authenticate
      Account.create!(fake: create!)
    end
  end
end
