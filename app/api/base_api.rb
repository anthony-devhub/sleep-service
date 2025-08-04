class BaseApi < Grape::API
  format :json
  prefix :api
  version 'v1', using: :path

  mount V1::UsersApi
  mount V1::FollowsApi

  rescue_from ActiveRecord::RecordNotFound do |e|
    present_error(e.message, code: 404)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    present_error(e.record.errors.full_messages.join(', '), code: 422)
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    present_error(e.full_messages.join(', '), code: 400)
  end

  rescue_from :all do |e|
    present_error("Internal server error", code: 500)
  end

  if Rails.env.development?
    add_swagger_documentation(
      api_version: 'v1',
      hide_documentation_path: true,
      mount_path: '/swagger',
      hide_format: true,
      info: {
        title: 'Test Prep API',
        description: 'API documentation for the Test Prep'
      }
    )
  end
end
