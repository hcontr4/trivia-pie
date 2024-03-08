require "sinatra"
require "sinatra/reloader"

require "http"
require "json"

CATEGORY_CODE = {
  "film" => 11,
  "science" => 17,
  "history" => 23,
  "sports" => 21,
  "geography" => 22
}

get("/") do
  erb(:landing)
end

get("/:category") do
  @category = params[:category]

  api_url = "https://opentdb.com/api.php?amount=1&category=#{CATEGORY_CODE[@category]}&difficulty=medium&type=multiple"
  raw_response = HTTP.get(api_url)
  parsed_response = JSON.parse(raw_response)

  question_block = parsed_response["results"].first

  @question = question_block["question"]
  @correct_answer = question_block["correct_answer"]
  @options = (question_block["incorrect_answers"] << @correct_answer).shuffle()
  
  erb(:question)
end

get("/:category/correct") do
  "RIGHTTTT"
end

get("/:category/incorrect") do
  "WRONGGGG"
end
