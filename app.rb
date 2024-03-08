require "sinatra"
require "sinatra/reloader"

get("/") do
  erb(:landing)
end
