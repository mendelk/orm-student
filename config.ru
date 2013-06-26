require './app'
use Rack::MethodOverride
run StudentSite::App.new