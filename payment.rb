require "sinatra"
require_relative "base_code"

configure do
end

post "/pay" do
  content_type :json
  { state: params[:amount].to_i.even? ? :success : :failure }.to_json
end
