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

A resposta da análise é baseada no mês da data de expiração do cartão de crédito utilizado na compra.

* Análise manual (manual_analysis/AMA): `11`
* Fraude (fraud/FRD): `12`
* Aprovado (approved/APA): Qualquer outro mês que não seja 11 e 12 terá sua respectiva compra aprovada.
