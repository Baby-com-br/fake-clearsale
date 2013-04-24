module FakeClearsale
  class App < Sinatra::Base
    get "/" do
      wsdl
    end

    post "/" do
      doc = Nokogiri::XML(request.body.read.gsub(/&lt;/, "<").gsub(/&gt;/, ">"))

      if !doc.xpath("//int:SendOrders").empty?
        process_send_orders doc
      elsif !doc.xpath("//int:GetOrderStatus").empty?
        order_id = doc.xpath("//orderID").inner_text
        process_get_order_status order_id
      else
        wsdl
      end
    end

    post "/GetAnalystComments" do
      @order_id = params[:orderID]

      erb :analyst_comments
    end

    private

    def process_send_orders(xml)
      order = xml.at_css('Orders > Order')

      @id = order.at('ID').text
      @credit_card = order.at('Payments CardNumber').text
      @status, @score = status_and_score(@credit_card)

      save_order(@id, {
        "status" => @status,
        "score"  => @score
      })

      callback(@id, @status, @score)

      erb :order
    end

    def process_get_order_status(order_id)
      @order_id = order_id
      order = order(@order_id)

      if order
        @status, @score = order["status"], order["score"]
        erb :order_status, :format => :xml
      else
        erb :empty_response, :format => :xml
      end
    end

    def save_order(order_id, params)
      redis.set "orders_#{order_id}", params.to_json
    end

    def order(order_id)
      redis_response = redis.get "orders_#{order_id}"
      unless redis_response.nil?
        Yajl::Parser.parse(redis_response)
      end
    end

    def clear_orders
      keys = redis.keys("orders_*")
      redis.del *keys if keys.any?
    end

    def callback(order_id, status, score)
      return unless Settings.callback_url

      request = HTTPI::Request.new
      request.url = Settings.callback_url
      request.body = {
        :ID => order_id,
        :Status => status,
        :Score => score
      }

      HTTPI.post request
    end

    def status_and_score(credit_card)
      case credit_card
      when "4242424242424242"
        ["APA", "95.9800"]
      when "5555555555555555"
        ["AMA", "70.9010"]
      else
        ["FRD", "40.9320"]
      end
    end

    def wsdl
      headers "Cache-Control" => "private, max-age=0", "Content-Type" => "text/xml"
      path = File.join(File.dirname(__FILE__), "../clearsale/wsdl.xml")
      send_file path
    end
  end
end
