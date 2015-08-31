Rails.application.config.middleware.use OmniAuth::Builder do
  provider :venmo, ENV['VENMO_KEY'], ENV['VENMO_SECRET']
end
