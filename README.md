# Desafio Dev Backend Jr - Patrick Santos

Este é o repositório da aplicação desenvolvida para o processo seletivo da Mainô para a vaga de Desenvolvedor Backend Junior. A aplicação realiza o processamento de arquivos XML, gerando relatórios detalhados com informações extraídas dos documentos fiscais.

## Tecnologias Utilizadas

- **Ruby on Rails**
- **Devise** (autenticação)
- **Sidekiq** (processamento em background)
- **PostgreSQL**
- **RSpec** (testes automatizados)
- **TailwindCSS** (estilização)
- 
## Funcionalidades

- **Autenticação de Usuário**: Sistema de login seguro, garantindo que apenas usuários autenticados possam acessar a aplicação.
- **Upload de Documentos**: Interface para envio de arquivos XML para processamento.
- **Processamento em Background**: Utiliza Sidekiq para processar os arquivos XML em segundo plano.
- **Relatórios**: Gera relatórios detalhados com dados do documento fiscal, produtos listados e impostos associados.
- **Filtros**: Filtros no relatório para facilitar a busca e visualização das informações processadas.

## Diferenciais

- **Testes Automatizados**: Implementação de testes automatizados utilizando RSpec para as funcionalidades principais.
- **Processamento de Lote**: Possibilidade de importar um arquivo ZIP contendo vários documentos XML.
- **Exportação em Excel**: Possibilidade de se exportar um relatório com todas as informaçoes em Excel.


## Como Executar o Projeto Localmente

### Pré-requisitos


- Ruby 3.0.0+
- Rails 7.0.0+
- PostgreSQL
- Redis (para Sidekiq)

### Instalação


1. Clone este repositório:


```bash
git clone https://github.com/PatrickSantos/desafio-maino.git
cd desafio-maino
```

2. Instale as dependências:

```bash
bundle install
```

3. Configure o banco de dados:

```bash
rails db:create
rails db:migrate
```

4. Configure o Redis (necessário para o Sidekiq):
Inicie o Redis na sua máquina:

```bash
redis-server
```

5. Execute o Sidekiq:

```bash
bundle exec sidekiq
```

6. Execute o servidor:
   
```bash
bin/dev
```

7. Acesse [http://localhost:3000](http://localhost:3000) no seu navegador.


## Testes:

Para rodar os testes automatizados:

```bash
bundle exec rspec
```

### Links

- Link para a aplicação em produção : [{deploy}](https://desafio-maino-patrick.onrender.com)
- Repo do Github: https://github.com/patricksanto/desafio_maino_patrick

  
## Contato
- [LinkedIn](https://www.linkedin.com/in/patricksanto/)
- Email: patricksantos@example.com
