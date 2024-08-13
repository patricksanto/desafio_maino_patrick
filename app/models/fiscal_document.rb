class FiscalDocument < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :taxes, dependent: :destroy
end
