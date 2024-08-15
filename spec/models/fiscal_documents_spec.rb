RSpec.describe FiscalDocument, type: :model do
  it "is valid with valid attributes" do
    fiscal_document = FiscalDocument.new(
      serie: "123",
      nNF: "456",
      dhEmi: Time.current,
      emitente: { cnpj: "12345678000195", nome: "Empresa Emitente", endereco: { rua: "Rua A", numero: "123", bairro: "Centro", cidade: "São Paulo", uf: "SP" } },
      destinatario: { cnpj: "98765432000198", nome: "Empresa Destinatária", endereco: { rua: "Rua B", numero: "456", bairro: "Bairro", cidade: "Rio de Janeiro", uf: "RJ" } }
    )
    expect(fiscal_document).to be_valid
  end

  it "is not valid without a serie" do
    fiscal_document = FiscalDocument.new(serie: nil)
    expect(fiscal_document).not_to be_valid
  end

  it "is not valid without a nNF" do
    fiscal_document = FiscalDocument.new(nNF: nil)
    expect(fiscal_document).not_to be_valid
  end

  it "is not valid without dhEmi" do
    fiscal_document = FiscalDocument.new(dhEmi: nil)
    expect(fiscal_document).not_to be_valid
  end

  it "is not valid without emitente" do
    fiscal_document = FiscalDocument.new(emitente: nil)
    expect(fiscal_document).not_to be_valid
  end

  it "is not valid without destinatario" do
    fiscal_document = FiscalDocument.new(destinatario: nil)
    expect(fiscal_document).not_to be_valid
  end
end
