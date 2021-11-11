require "sinatra"
require_relative "base_code"
require "json"

configure do

  settings.nats.subscribe("order_success") do |msg|

    res = JSON.parse(msg)
    orderId = res['orderId']
    amount = res['amount']
    
    if amount.to_i > 50 then
        state = :failure
        settings.nats.publish("order_compensating_action", {:state => state, :orderId => orderId, :message => "error amount higher than 50" }.to_json)
    end

  end
end