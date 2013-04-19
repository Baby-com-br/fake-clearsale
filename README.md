# Fake ClearSale

Webservice Fake da Clearsale, útil para executar testes de perfomance e integração END-2-END em aplicações que dependam da Clearsale, visto que a mesma não disponibiliza um sandbox.

# Instalação usando o RVM

 - Entre no diretório do projeto;
 - Execute `rvm install ruby-1.9.2` para instalar o ruby;
 - Execute `rvm use ruby-1.9.2`;
 - Instale o bundler com `gem install bundler`;
 - Instale as dependências do projeto com `bundle install`;
 - Execute `bundle exec unicorn -p <porta>` para iniciar o webservice.

# Utilização

A resposta da análise é baseada no número do cartão de crédito da compra.

* Análise manual (manual_analysis/AMA): `5555 5555 5555 5555`
* Aprovado (approved/APA): `4242 4242 4242 4242`
* Fraude (fraud/FRD): Qualquer número de cartão será marcado como fraude (exceto dos itens acima).
