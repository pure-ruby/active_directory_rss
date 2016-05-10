# -*- encoding: utf-8 -*-

require %-rubygems-
require %-bundler/setup-
require_relative %-app-

configure do
  use Sass::Plugin::Rack
  Sass::Plugin.options[:style] = :compact
  set :haml, :format => :html4, layout: false
  CONFIG = YAML.load_file('conf.yml')
  T_ZONE = "+0500"
end

configure :development do
  enable :show_exceptions, :dump_errors
  # set :port, 4010
  # set :bind, '0.0.0.0'
end

configure :production do
  # set :port, 4000
  # set :bind, '127.0.0.1'
  set :logging, true
  set :dump_errors, false
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

run Sinatra::Application