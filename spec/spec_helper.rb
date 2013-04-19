# encoding: utf-8
require 'rspec'
require 'rack/test'
require "pry"

ENV ||= {}
ENV["SINATRA_ENV"] = "test"

$:.unshift File.dirname(File.expand_path(__FILE__)) + "/lib"
require "fake_clearsale"
Dir[File.dirname(__FILE__) + "/support/*.rb"].each { |f| require f }

def app
  FakeClearsale::App
end

RSpec.configure do |config|
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.include Rack::Test::Methods
end

def make_clearsale_xml(name, order_id)
  <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<ClearSale>
<Orders>
  <Order>
    <ID>#{order_id}</ID>
    <Date>2011-11-30T11:35:01</Date>
    <Email>foo@example.com</Email>
    <!-- <B2B_B2C></B2B_B2C> -->
    <ShippingPrice>40.2</ShippingPrice>
    <TotalItens>59.8</TotalItens>
    <TotalOrder>100</TotalOrder>
    <QtyInstallments>8</QtyInstallments>
    <!-- <DeliveryTimeCD></DeliveryTimeCD> -->
    <QtyItems>3</QtyItems>
    <!-- <QtyPaymentTypes></QtyPaymentTypes> -->

    <IP>127.0.0.1</IP>

    <!-- <GiftMessage></GiftMessage>
    <Obs></Obs>
    <Status></Status>
    <Reanalise></Reanalise>
    <Origin></Origin>
    <ReservationDate></ReservationDate> -->
    <CollectionData>
      <ID>10</ID>
      <Type>1</Type>
      <LegalDocument1>03042445030</LegalDocument1>
      <!-- <LegalDocument2></LegalDocument2> -->
      <Name>#{name}</Name>
      <!-- <BirthDate></BirthDate> -->
      <Email>foo@example.com</Email>
      <!-- <Genre></Genre> -->
      <Address>
        <Street>Rua Bla</Street>
        <Number>100</Number>
        <Comp></Comp>
        <County>Vila Maria</County>
        <City>New York</City>
        <State>Missouri</State>
        <Country>BR</Country>
        <ZipCode>99020010</ZipCode>
        <!-- <Reference></Reference> -->
      </Address>
      <Phones>

        <Phone>
          <Type>2</Type>
          <!-- <DDI></DDI> -->
          <DDD>11</DDD>
          <Number>9020202</Number>
          <!-- <Extension></Extension> -->
        </Phone>

      </Phones>
    </CollectionData>
    <ShippingData>
      <ID>10</ID>
      <Type>1</Type>
      <LegalDocument1>03042445030</LegalDocument1>
      <!-- <LegalDocument2></LegalDocument2> -->
      <Name>#{name}</Name>
      <!-- <BirthDate></BirthDate> -->
      <Email>foo@example.com</Email>
      <!-- <Genre></Genre> -->
      <Address>
        <Street>Rua Bla</Street>
        <Number>100</Number>
        <Comp></Comp>
        <County>Vila Maria</County>
        <City>New York</City>
        <State>Missouri</State>
        <Country>BR</Country>
        <ZipCode>99020010</ZipCode>
        <!-- <Reference></Reference> -->
      </Address>
      <Phones>

        <Phone>
          <Type>2</Type>
          <!-- <DDI></DDI> -->
          <DDD>11</DDD>
          <Number>89383893</Number>
          <!-- <Extension></Extension> -->
        </Phone>

      </Phones>
    </ShippingData>
    <Payments>
      <Payment>
        <!-- <Sequential></Sequential> -->
        <Date>2011-11-30T19:25:18</Date>
        <Amount>100</Amount>
        <PaymentTypeID>11</PaymentTypeID>
        <QtyInstallments>8</QtyInstallments>
        <!-- <Interest></Interest>
        <InterestValue></InterestValue> -->

      </Payment>
    </Payments>
    <Items>

      <Item>
        <ID>1</ID>
        <Name>Luva de box com ferradura dentro</Name>
        <ItemValue>30.3</ItemValue>
        <!-- <Generic></Generic> -->
        <Qty>1</Qty>
        <!-- <GiftTypeID></GiftTypeID>
        <CategoryID></CategoryID>
        <CategoryName></CategoryName> -->
      </Item>

      <Item>
        <ID>2</ID>
        <Name>Luva de box com cavalo dentro</Name>
        <ItemValue>30</ItemValue>
        <!-- <Generic></Generic> -->
        <Qty>1</Qty>
        <!-- <GiftTypeID></GiftTypeID>
        <CategoryID></CategoryID>
        <CategoryName></CategoryName> -->
      </Item>

      <Item>
        <ID>3</ID>
        <Name>Cavalo com ferradura de box</Name>
        <ItemValue>40</ItemValue>
        <!-- <Generic></Generic> -->
        <Qty>1</Qty>
        <!-- <GiftTypeID></GiftTypeID>
        <CategoryID></CategoryID>
        <CategoryName></CategoryName> -->
      </Item>

    </Items>
  </Order>
</Orders>
</ClearSale>
  EOXML
end
