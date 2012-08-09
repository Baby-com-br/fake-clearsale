module FakeClearsale
  class App < Sinatra::Base
    get "/" do
      wsdl
    end

    post "/" do
      wsdl
    end

    post "/SendOrders" do
      order = Nokogiri::XML(params[:xml]).css('Orders > Order')

      @id = order.at('ID').text
      @name = order.at('CollectionData > Name').text
      @status, @score = status_and_score(@name)

      save_order(@id, {
        "name"   => @name,
        "status" => @status,
        "score"  => @score
      })

      callback(@id, @status, @score)

      erb :order
    end

    post "/GetOrderStatus" do
      @order_id = params[:orderID]
      order = order(@order_id)

      @status, @score = order["status"], order["score"]

      erb :order_status
    end

    post "/GetAnalystComments" do
      @order_id = params[:orderID]

      erb :analyst_comments
    end

    private
    def save_order(order_id, params)
      redis.set "orders_#{order_id}", params.to_json
    end

    def order(order_id)
      Yajl::Parser.parse(redis.get("orders_#{order_id}"))
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

    def status_and_score(name)
      name == "Fulano Confiavel" ? ["APA", "95.9800"] : ["RPA", "40.9320"]
    end

    def wsdl
      headers "Cache-Control" => "private, max-age=0", "Content-Type" => "text/xml"
      path = File.join(File.dirname(__FILE__), "../clearsale/wsdl.xml")
      send_file path
    end
  end
end
