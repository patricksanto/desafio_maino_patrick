class XmlProcessorJob
  include Sidekiq::Job

  def perform(data)
    fiscal_document_data = data["fiscal_document"]
    products_data = data["products"]
    taxes_data = data["taxes"]

    fiscal_document = FiscalDocument.new(
      serie: fiscal_document_data["serie"],
      nNF: fiscal_document_data["nNF"],
      dhEmi: fiscal_document_data["dhEmi"],
      emitente: fiscal_document_data["emitente"],
      destinatario: fiscal_document_data["destinatario"]
    )

    if fiscal_document.save!
      create_products(fiscal_document, products_data)
      create_taxes(fiscal_document, taxes_data)
    else
      raise ActiveRecord::RecordInvalid.new(fiscal_document)
    end
  end

  private

  def create_products(fiscal_document, products_data)
    products_data.each do |product_data|
      fiscal_document.products.create!(
        name: product_data["name"],
        ncm: product_data["ncm"],
        cfop: product_data["cfop"],
        unit: product_data["unit"],
        quantity: product_data["quantity"].to_d,
        value: product_data["value"].to_d
      )
    end
  end

  def create_taxes(fiscal_document, taxes_data)
    fiscal_document.taxes.create!(
      icms: taxes_data["icms"].to_d,
      ipi: taxes_data["ipi"].to_d,
      pis: taxes_data["pis"].to_d,
      cofins: taxes_data["cofins"].to_d
    )
  end
end
