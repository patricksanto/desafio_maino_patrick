class Tax < ApplicationRecord
  belongs_to :fiscal_document

  validates :icms, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :ipi, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :pis, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cofins, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
