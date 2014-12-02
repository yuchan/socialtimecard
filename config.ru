require "sinatra"
require "./app"

map "/" do
  run App
end
