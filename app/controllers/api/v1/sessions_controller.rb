class Api::V1::SessionsController < Devise::SessionsController
  protect_from_forgery with: :null_session
  respond_to :json

  def create
    self.resource = warden.authenticate!(auth_options.merge(scope: :user))
    sign_in(resource_name, resource)
    yield resource if block_given?

    render json: { resource: resource, token: current_token }
  end

  private

  def resource_name
    :user
  end

  def current_token
    request.env['warden-jwt_auth.token']
  end
end
