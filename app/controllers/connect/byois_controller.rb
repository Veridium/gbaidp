class Connect::ByoisController < ApplicationController
    before_filter :require_anonymous_access
  
    def create
      authenticate Connect::Byoi.authenticate
      logged_in!
    end
  end
  