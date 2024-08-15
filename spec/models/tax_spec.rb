RSpec.describe Tax, type: :model do
  let(:fiscal_document) { create(:fiscal_document) }

  it "is valid with valid attributes" do
    tax = fiscal_document.taxes.new(
      icms: 10.0,
      ipi: 5.0,
      pis: 1.0,
      cofins: 2.0
    )
    expect(tax).to be_valid
  end

  it "is not valid without icms" do
    tax = fiscal_document.taxes.new(icms: nil)
    expect(tax).not_to be_valid
  end

  it "is not valid without ipi" do
    tax = fiscal_document.taxes.new(ipi: nil)
    expect(tax).not_to be_valid
  end

  it "is not valid without pis" do
    tax = fiscal_document.taxes.new(pis: nil)
    expect(tax).not_to be_valid
  end

  it "is not valid without cofins" do
    tax = fiscal_document.taxes.new(cofins: nil)
    expect(tax).not_to be_valid
  end
end
