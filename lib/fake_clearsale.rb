require "bundler/setup"

Bundler.require 

$:.unshift File.dirname(File.expand_path(__FILE__)) + "/lib"

module FakeClearsale
  class App < Sinatra::Base
    post "/SendOrders" do
      order = Nokogiri::XML(params[:xml]).css('Orders > Order')

      id = order.at('ID').text
      name = order.at('CollectionData > Name').text

      save_request(id, name)
      status, score = status_and_score(name)

      <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<string xmlns="http://www.clearsale.com.br/integration">&lt;?xml version="1.0" encoding="utf-16"?&gt;
&lt;PackageStatus&gt;
  &lt;TransactionID&gt;#{id}&lt;/TransactionID&gt;
  &lt;StatusCode&gt;00&lt;/StatusCode&gt;
  &lt;Message&gt;OK&lt;/Message&gt;
  &lt;Orders&gt;
    &lt;Order&gt;
      &lt;ID&gt;#{id}&lt;/ID&gt;
      &lt;Status&gt;#{status}&lt;/Status&gt;
      &lt;Score&gt;#{score}&lt;/Score&gt;
    &lt;/Order&gt;
  &lt;/Orders&gt;
&lt;/PackageStatus&gt;</string>
      EOXML
    end

    post "/GetOrderStatus" do
      status, score = status_and_score(@@received_requests[params[:orderID]])

      <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<string xmlns="http://www.clearsale.com.br/integration">&lt;?xml version="1.0" encoding="utf-16"?&gt;
&lt;ClearSale&gt;
  &lt;Orders&gt;
    &lt;Order&gt;
      &lt;ID&gt;#{params[:orderID]}&lt;/ID&gt;
      &lt;Status&gt;#{status}&lt;/Status&gt;
      &lt;Score&gt;#{score}&lt;/Score&gt;
    &lt;/Order&gt;
  &lt;/Orders&gt;
&lt;/ClearSale&gt;</string>
      EOXML
    end

    post "/GetAnalystComments" do
      <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<string xmlns="http://www.clearsale.com.br/integration">&lt;?xml version="1.0" encoding="utf-16"?&gt;
&lt;Order&gt;
  &lt;ID&gt;#{params[:orderID]}&lt;/ID&gt;
  &lt;Date d2p1:nil="true" xmlns:d2p1="http://www.w3.org/2001/XMLSchema-instance" /&gt;
  &lt;QtyInstallments d2p1:nil="true" xmlns:d2p1="http://www.w3.org/2001/XMLSchema-instance" /&gt;
  &lt;ShippingPrice d2p1:nil="true" xmlns:d2p1="http://www.w3.org/2001/XMLSchema-instance" /&gt;
  &lt;ShippingTypeID&gt;0&lt;/ShippingTypeID&gt;
  &lt;ManualOrder&gt;
    &lt;ManualQuery d3p1:nil="true" xmlns:d3p1="http://www.w3.org/2001/XMLSchema-instance" /&gt;
    &lt;UserID&gt;0&lt;/UserID&gt;
  &lt;/ManualOrder&gt;
  &lt;TotalItens&gt;0&lt;/TotalItens&gt;
  &lt;TotalOrder&gt;0&lt;/TotalOrder&gt;
  &lt;Gift&gt;0&lt;/Gift&gt;
  &lt;Status&gt;-1&lt;/Status&gt;
  &lt;Reanalise&gt;0&lt;/Reanalise&gt;
  &lt;WeddingList d2p1:nil="true" xmlns:d2p1="http://www.w3.org/2001/XMLSchema-instance" /&gt;
  &lt;ReservationDate d2p1:nil="true" xmlns:d2p1="http://www.w3.org/2001/XMLSchema-instance" /&gt;
  &lt;ShippingData&gt;
    &lt;Type d3p1:nil="true" xmlns:d3p1="http://www.w3.org/2001/XMLSchema-instance" /&gt;
    &lt;BirthDate d3p1:nil="true" xmlns:d3p1="http://www.w3.org/2001/XMLSchema-instance" /&gt;
    &lt;Phones /&gt;
    &lt;Address /&gt;
  &lt;/ShippingData&gt;
  &lt;CollectionData&gt;
    &lt;Type d3p1:nil="true" xmlns:d3p1="http://www.w3.org/2001/XMLSchema-instance" /&gt;
    &lt;BirthDate d3p1:nil="true" xmlns:d3p1="http://www.w3.org/2001/XMLSchema-instance" /&gt;
    &lt;Phones /&gt;
    &lt;Address /&gt;
  &lt;/CollectionData&gt;
  &lt;Payments /&gt;
  &lt;Items /&gt;
  &lt;Passangers /&gt;
  &lt;Connections /&gt;
  &lt;AnalystComments&gt;
    &lt;AnalystComments&gt;
      &lt;CreateDate&gt;2011-12-06T18:04:54.033&lt;/CreateDate&gt;
      &lt;Comments&gt;outro teste de observacao&lt;/Comments&gt;
      &lt;UserName /&gt;
      &lt;Status&gt;RPM&lt;/Status&gt;
      &lt;LineName&gt;FILA GERAL&lt;/LineName&gt;
    &lt;/AnalystComments&gt;
    &lt;AnalystComments&gt;
      &lt;CreateDate&gt;2011-12-06T18:04:37.723&lt;/CreateDate&gt;
      &lt;Comments&gt;teste de observacao&lt;/Comments&gt;
      &lt;UserName /&gt;
      &lt;Status&gt;RPM&lt;/Status&gt;
      &lt;LineName&gt;FILA GERAL&lt;/LineName&gt;
    &lt;/AnalystComments&gt;
  &lt;/AnalystComments&gt;
&lt;/Order&gt;</string>
      EOXML
    end

    private
    def save_request(order_id, name)
      @@received_requests ||= {}
      @@received_requests[order_id] = name
    end

    def clear_requests
      @@received_requests.clear
    end

    def status_and_score(name)
      if name == "Fulano Confiavel"
        ["APA", "95.9800"]
      else
        ["RPA", "40.9320"]
      end
    end

    configure do
      set :show_expections, false
    end
  end
end
