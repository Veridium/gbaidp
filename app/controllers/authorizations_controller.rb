class AuthorizationsController < ApplicationController
  protect_from_forgery except: :ping

  rescue_from Rack::OAuth2::Server::Authorize::BadRequest do |e|
    @error = e
    logger.info e.backtrace[0,10].join("\n")
    render :error, status: e.status
  end

  def new
    call_authorization_endpoint
  end

  def testme
    return (Account.find_by_identifier(current_account.identifier).approved || false)
  end

  def create
    call_authorization_endpoint testme, params[:approve]
  end

  def ping
    account = Account.find_by_identifier(params[:id])
    account.email = params[:email]
    account.approved = true
    account.save!
    rescue NoMethodError
  end

  private

  def qrimage(val)
    qrcode = RQRCode::QRCode.new(val)
    return qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 120
    )
  end

  def call_authorization_endpoint(allow_approval = false, approved = false)
    endpoint = AuthorizationEndpoint.new current_account, allow_approval, approved
    rack_response = *endpoint.call(request.env)
    @client, @response_type, @redirect_uri, @scopes, @_request_, @request_uri, @request_object = *[
      endpoint.client, endpoint.response_type, endpoint.redirect_uri, endpoint.scopes, endpoint._request_, endpoint.request_uri, endpoint.request_object
    ]
    require_authentication
    if (
      !allow_approval &&
      (max_age = @request_object.try(:id_token).try(:max_age)) &&
      current_account.last_logged_in_at < max_age.seconds.ago
    )
      flash[:notice] = 'Exceeded Max Age, Login Again'
      unauthenticate!
      require_authentication
    end
    qrvalue = ENV["SITE_QRCODE_URL"] + ":" + ENV["SITE_QRCODE_PORT"] + "/approve/" + current_account.identifier
    @accountid = current_account.identifier
    @qrpng = qrimage(qrvalue).resize(250,250).to_data_url
    respond_as_rack_app *rack_response
  end

  def respond_as_rack_app(status, header, response)
    ["WWW-Authenticate"].each do |key|
      headers[key] = header[key] if header[key].present?
    end
    if response.redirect?
      redirect_to header['Location']
    else
      render :new
    end
  end
end
