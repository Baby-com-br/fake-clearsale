# encoding: utf-8
require 'spec_helper'

describe FakeClearsale::App do
  describe "POST SendOrders" do
    it "should respond approved as status" do
      post "/", send_orders_xml("1234", "4242424242424242")

      last_response.body.should == <<-EOF
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">
  <soap:Body>
    <SendOrdersResponse xmlns=\"http://www.clearsale.com.br/integration\">
      <SendOrdersResult>
          &lt;PackageStatus&gt;
            &lt;TransactionID&gt;b184644f-fbb5-4c5d-a04f-bd1564ddf2a8&lt;/TransactionID&gt;
            &lt;StatusCode&gt;00&lt;/StatusCode&gt;
            &lt;Message&gt;OK&lt;/Message&gt;
            &lt;Orders&gt;
              &lt;Order&gt;
                &lt;ID&gt;1234;&lt;/ID&gt;
                &lt;Status&gt;APA&lt;/Status&gt;
                &lt;Score&gt;95.9800&lt;/Score&gt;
              &lt;/Order&gt;
            &lt;/Orders&gt;
          &lt;/PackageStatus&gt;
      </SendOrdersResult>
    </SendOrdersResponse>
  </soap:Body>
</soap:Envelope>
EOF
    end

    it "should respond manual analysis as status" do
      post "/", send_orders_xml("8321", "5555555555555555")

      last_response.body.should == <<-EOF
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">
  <soap:Body>
    <SendOrdersResponse xmlns=\"http://www.clearsale.com.br/integration\">
      <SendOrdersResult>
          &lt;PackageStatus&gt;
            &lt;TransactionID&gt;b184644f-fbb5-4c5d-a04f-bd1564ddf2a8&lt;/TransactionID&gt;
            &lt;StatusCode&gt;00&lt;/StatusCode&gt;
            &lt;Message&gt;OK&lt;/Message&gt;
            &lt;Orders&gt;
              &lt;Order&gt;
                &lt;ID&gt;8321;&lt;/ID&gt;
                &lt;Status&gt;AMA&lt;/Status&gt;
                &lt;Score&gt;70.9010&lt;/Score&gt;
              &lt;/Order&gt;
            &lt;/Orders&gt;
          &lt;/PackageStatus&gt;
      </SendOrdersResult>
    </SendOrdersResponse>
  </soap:Body>
</soap:Envelope>
EOF
    end

    it "should respond reproved as status" do
      post "/", send_orders_xml("4321", "5555555555554444")

      last_response.body.should == <<-EOF
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">
  <soap:Body>
    <SendOrdersResponse xmlns=\"http://www.clearsale.com.br/integration\">
      <SendOrdersResult>
          &lt;PackageStatus&gt;
            &lt;TransactionID&gt;b184644f-fbb5-4c5d-a04f-bd1564ddf2a8&lt;/TransactionID&gt;
            &lt;StatusCode&gt;00&lt;/StatusCode&gt;
            &lt;Message&gt;OK&lt;/Message&gt;
            &lt;Orders&gt;
              &lt;Order&gt;
                &lt;ID&gt;4321;&lt;/ID&gt;
                &lt;Status&gt;FRD&lt;/Status&gt;
                &lt;Score&gt;40.9320&lt;/Score&gt;
              &lt;/Order&gt;
            &lt;/Orders&gt;
          &lt;/PackageStatus&gt;
      </SendOrdersResult>
    </SendOrdersResponse>
  </soap:Body>
</soap:Envelope>
EOF
    end
  end

  describe "POST GetOrderStatus" do
    context "when order was approved" do
      before do
        post "/", send_orders_xml("9324", "4242424242424242")
      end

      it "should respond approved as status" do
        post "/", get_status_xml('9324')

        last_response.body.should == <<-EOF
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\"
  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
  xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">
  <soap:Body>
      &lt;ClearSale&gt;
        &lt;Orders&gt;
          &lt;Order&gt;
            &lt;ID&gt;9324&lt;/ID&gt;
            &lt;Status&gt;APA&lt;/Status&gt;
            &lt;Score&gt;95.9800&lt;/Score&gt;
          &lt;/Order&gt;
        &lt;/Orders&gt;
      &lt;/ClearSale&gt;
  </soap:Body>
</soap:Envelope>
EOF
      end

    end

    context "when order was reproved" do
      before do
        post "/", {
          :xml => send_orders_xml("Fulano Estranho", "LOL")
        }
      end

      it "should respond reproved as status" do
        post "/", get_status_xml('LOL')

        last_response.body.should == <<-EOF
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\"
  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
  xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">
  <soap:Body>
      &lt;ClearSale&gt;
        &lt;Orders&gt;
          &lt;Order&gt;
            &lt;ID&gt;LOL&lt;/ID&gt;
            &lt;Status&gt;FRD&lt;/Status&gt;
            &lt;Score&gt;40.9320&lt;/Score&gt;
          &lt;/Order&gt;
        &lt;/Orders&gt;
      &lt;/ClearSale&gt;
  </soap:Body>
</soap:Envelope>
EOF
      end
    end
  end

  describe "POST GetAnalystComments" do
    it "should respond with some comments" do
      post "/GetAnalystComments", :orderID => "meuorderid"

      last_response.body.should == <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<string xmlns="http://www.clearsale.com.br/integration">&lt;?xml version="1.0" encoding="utf-16"?&gt;
&lt;Order&gt;
  &lt;ID&gt;meuorderid&lt;/ID&gt;
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
      EOF
    end
  end
end
