FactoryBot.define do
  factory :fiscal_document do
    serie { Faker::Number.number(digits: 3) }
    nNF { Faker::Number.number(digits: 6) }
    dhEmi { Faker::Time.backward(days: 14) }
    emitente { { 'cnpj' => Faker::Company.ein, 'nome' => Faker::Company.name } }
    destinatario { { 'cnpj' => Faker::Company.ein, 'nome' => Faker::Company.name } }
  end
end
