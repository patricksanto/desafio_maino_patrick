class Product < ApplicationRecord
  belongs_to :fiscal_document

  validates :name, :ncm, :cfop, :unit, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :value, presence: true, numericality: { greater_than: 0 }
end
