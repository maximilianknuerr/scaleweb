require "sinatra"
require_relative "base_code"

configure do

  settings.nats.subscribe("order") do |msg|

    res = JSON.parse(msg)
    orderId = res['orderId']
    amount = res['amount']
    state = :failure
    sleep(0.5)
    if amount.to_i.even? then
      state = :success
    else
      state = :failure
    end
    puts state
    settings.nats.publish("payment", { :state => state, :orderId => orderId, :amount => amount, }.to_json)

    
  end

  settings.nats.subscribe("order_compensating_action") do |msg|
    res = JSON.parse(msg)
    orderId = res["orderId"]
    message = res["message"]
    puts "order #{orderId} order failed: #{message}!"
  end
end

