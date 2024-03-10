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
  redirect to "/game"
end

get("/reset-game") do 
  cookies[:slice_status] = JSON.generate({
    "film" => false,
    "science" => false,
    "history" => false,
    "sports" => false,
    "geography" => false,
  })

  redirect to "/game"
end

get("/complete-pie") do
  @slice_status = JSON.parse(cookies[:slice_status])
  erb(:complete)
end

get("/game") do
  pie_status = cookies[:slice_status]
  redirect to "/reset-game" if pie_status.nil?

  @slice_status = JSON.parse(pie_status)
  erb(:game)
end

get("/game/:category") do
  @category = params[:category]

  api_url = "https://opentdb.com/api.php?amount=1&category=#{CATEGORY_CODE[@category]}&difficulty=medium&type=multiple"
  raw_response = HTTP.get(api_url)
  parsed_response = JSON.parse(raw_response)
  # api call did not return question, wait a bit and ask again
  unless parsed_response["response_code"] == 0
    sleep(0.2)
    redirect ("/game/#{@category}")
  end

  question_block = parsed_response["results"].first

  @question = question_block["question"]
  @correct_answer = question_block["correct_answer"]
  @options = (question_block["incorrect_answers"] << @correct_answer).shuffle()

  cookies[:question] = @question
  cookies[:correct_answer] = @correct_answer
  cookies[:options] = JSON.generate(@options)

  erb(:question)
end

get("/game/:category/correct") do
  @category = params[:category]
  @question = cookies[:question]
  @correct_answer = cookies[:correct_answer]
  @options = JSON.parse(cookies[:options])

  # Retrieve game status and update 
  slice_status = JSON.parse(cookies[:slice_status])
  slice_status[@category] = true

  # Store updated status back in cookie
  cookies[:slice_status] = JSON.generate(slice_status)

  # Check for a complete pie 
  @complete_pie = true
  slice_status.each do | key, val| 
    @complete_pie = false unless val
  end

  #@status = slice_status
  erb(:reveal)
end

get("/game/:category/incorrect") do
  @category = params[:category]
  @question = cookies[:question]
  @correct_answer = cookies[:correct_answer]
  @options = JSON.parse(cookies[:options])

  erb(:reveal)
end
