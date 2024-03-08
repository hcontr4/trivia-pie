require "sinatra"
require "sinatra/reloader"
require "sinatra/cookies"

require "http"
require "json"

CATEGORY_CODE = {
  "film" => 11,
  "science" => 17,
  "history" => 23,
  "sports" => 21,
  "geography" => 22,
}

get("/") do
  erb(:landing)
end

get("/:category") do
  @category = params[:category]

  api_url = "https://opentdb.com/api.php?amount=1&category=#{CATEGORY_CODE[@category]}&difficulty=medium&type=multiple"
  raw_response = HTTP.get(api_url)
  parsed_response = JSON.parse(raw_response)
  # api call did not return question, wait a bit and ask again
  unless parsed_response["response_code"] == 0
    sleep(0.5)
    redirect ("/#{@category}")
  end

  question_block = parsed_response["results"].first

  @question = question_block["question"]
  @correct_answer = question_block["correct_answer"]
  @options = (question_block["incorrect_answers"] << @correct_answer).shuffle()

  erb(:question)
end

get("/:category/correct") do
  @category = params[:category]
  erb(:correct)
end

get("/:category/incorrect") do
  @category = params[:category]
  erb(:incorrect)
end
