Koala.configure do |config|
  config.access_token = ENV["token"]
  config.app_access_token = ENV["app_token"]
  config.app_id = ENV["app_id"]
  config.app_secret = ENV["secret_id"]
  # See Koala::Configuration for more options, including details on how to send requests through
  # your own proxy servers.
end

# ENV["app_id"]     = Figaro.env.app_id
# ENV["app_name"]   = Figaro.env.app_name
# ENV["client_id"]  = Figaro.env.client_id
# ENV["secret_id"]  = Figaro.env.secret_id
# ENV["token"]      = Figaro.env.token_id
# ENV["app_token"]  = Figaro.env.app_token
