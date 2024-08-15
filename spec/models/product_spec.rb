RSpec.describe Product, type: :model do
  let(:fiscal_document) { create(:fiscal_document) }

  it "is valid with valid attributes" do
    product = fiscal_document.products.new(
      name: "Produto A",
      ncm: "12345678",
      cfop: "5102",
      unit: "UN",
      quantity: 10,
      value: 100.0
    )
    expect(product).to be_valid
  end

  it "is not valid without a name" do
    product = fiscal_document.products.new(name: nil)
    expect(product).not_to be_valid
  end

  it "is not valid without a ncm" do
    product = fiscal_document.products.new(ncm: nil)
    expect(product).not_to be_valid
  end

  it "is not valid without a cfop" do
    product = fiscal_document.products.new(cfop: nil)
    expect(product).not_to be_valid
  end

  it "is not valid without a unit" do
    product = fiscal_document.products.new(unit: nil)
    expect(product).not_to be_valid
  end

  it "is not valid without a quantity" do
    product = fiscal_document.products.new(quantity: nil)
    expect(product).not_to be_valid
  end

  it "is not valid with a quantity less than or equal to 0" do
    product = fiscal_document.products.new(quantity: 0)
    expect(product).not_to be_valid
  end

  it "is not valid without a value" do
    product = fiscal_document.products.new(value: nil)
    expect(product).not_to be_valid
  end

  it "is not valid with a value less than or equal to 0" do
    product = fiscal_document.products.new(value: 0)
    expect(product).not_to be_valid
  end
end
