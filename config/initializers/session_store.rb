# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bcms_sitemap_session',
  :secret      => 'c85e145dc5e341b2418cd61e830e263292394fb87b006dfd729beae11762330119821b30c9e3e98f3ef92c028e4eabbd9b6590670d1028b1942efdd8bcda06df'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
