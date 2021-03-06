# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# for acts_as_searchable
# gem 'acts_as_searchable'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug
  $m = (defined? ActiveSupport) ? ActiveSupport::BufferedLogger.new(File.join(RAILS_ROOT, "log/my.log")) : Logger.new(File.join(RAILS_ROOT, "log/my.log"))

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_nrmss_session',
    :secret      => '4dec7ae44eb4a4e03ba64562805ab5193d1279b0a831edaf131ec60f4cc2598cd1cd94ab17e9631caca681d3f616ba3856146f43fd3cb45a7f6e9d7ebf0cddaf'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
end

# Load rms authentication yaml
rms_file = File.join(RAILS_ROOT, 'config', 'rms.yml')
if File.exist?(rms_file)
  Rakuten::RmsLogin.config = YAML::load(File.open(rms_file).read)
else
  raise FileNotFound, "#{rms_file} is not found."
end

# Load nrmss configuration yaml
module Nrmss
  @@config = {}
  mattr_accessor :config
end
nmrss_file = File.join(RAILS_ROOT, 'config', 'nrmss.yml')
if File.exist?(rms_file)
  Nrmss.config = YAML::load(File.open(rms_file).read)
else
  raise FileNotFound, "#{nrmss_file} is not found."
end

# Ruby-GetText-Package Rail plugin
require 'gettext/rails' rescue nil

ActionView::Base.class_eval do
  #defined?(_) || def _(*arg); arg; end
end
