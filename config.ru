require './app'
use Rack::MethodOverride
run FusionAuthApp.new
