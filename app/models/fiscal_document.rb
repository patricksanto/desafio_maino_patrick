class FiscalDocument < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :taxes, dependent: :destroy

  validates :serie, :nNF, :dhEmi, :emitente, :destinatario, presence: true

  def total_product_value
    products.sum(:value)
  end

  def total_tax_value
    tax = taxes.first
    tax.icms + tax.ipi + tax.pis + tax.cofins
  end

  def grand_total
    total_product_value + total_tax_value
  end
end
