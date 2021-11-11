require "sinatra"
require_relative "base_code"

configure do
  set :orders, {}
end

get "/" do
  @orders = settings.orders.values
  slim :index
end

post "/order" do
  order = Order.new
  settings.orders[order.id] = order

  response = HTTParty.post("http://payment:4567/pay", query: { amount: params[:amount] })
  response["state"] == "success" ?  order.success! : order.failure!

  redirect "/"
end
