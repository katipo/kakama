# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_kakama_session',
  :secret      => '969dae97531f10b7968c6d0ba37c420d5c32ddade78264b4c775db263dae79478d058f839bd88680291c1f9c6c8e9c05abf3a611ead5cd1821d7e23fce7a58ef'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
