require "sinatra"
require_relative "base_code"
require "json"

configure do
  set :orders, {}
  settings.nats.subscribe("payment") do |msg|
    res = JSON.parse(msg)
    amount = res['amount']
    orderId = res['orderId']
    order = settings.orders[orderId] 

    if res["state"] == "success" then
      order.success!
      settings.nats.publish("order_success", {:amount => amount, :orderId => orderId}.to_json)
    else
      order.failure!
    end
  
  end

  settings.nats.subscribe("order_compensating_action") do |msg|
    res = JSON.parse(msg)

    order = settings.orders[res["orderId"]]
    state = res["state"]
    if state == "failure" then
      order.failure!
    else
      order.success!
    end
  end
end

get "/" do
  @orders = settings.orders.values
  slim :index
end

post "/order" do
  order = Order.new
  settings.orders[order.id] = order
  
  settings.nats.publish("order", { :amount => params[:amount], :orderId => order.id }.to_json)

  redirect "/"

end
