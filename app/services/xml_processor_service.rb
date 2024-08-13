class XmlProcessorService
  def initialize(file)
    @file = file
    @xml_data = Nokogiri::XML(file.read)
    @namespaces = { 'nfe' => 'http://www.portalfiscal.inf.br/nfe' }
  end

  def call
    fiscal_document = create_fiscal_document
    create_products(fiscal_document)
    create_taxes(fiscal_document)
    fiscal_document
  end

  private

  def create_fiscal_document
    FiscalDocument.create(
      serie: @xml_data.xpath('//nfe:ide/nfe:serie', @namespaces).text,
      nNF: @xml_data.xpath('//nfe:ide/nfe:nNF', @namespaces).text,
      dhEmi: @xml_data.xpath('//nfe:ide/nfe:dhEmi', @namespaces).text,
      emitente: {
        cnpj: @xml_data.xpath('//nfe:emit/nfe:CNPJ', @namespaces).text,
        nome: @xml_data.xpath('//nfe:emit/nfe:xNome', @namespaces).text,
        endereco: {
          rua: @xml_data.xpath('//nfe:emit/nfe:enderEmit/nfe:xLgr', @namespaces).text,
          numero: @xml_data.xpath('//nfe:emit/nfe:enderEmit/nfe:nro', @namespaces).text,
          bairro: @xml_data.xpath('//nfe:emit/nfe:enderEmit/nfe:xBairro', @namespaces).text,
          cidade: @xml_data.xpath('//nfe:emit/nfe:enderEmit/nfe:xMun', @namespaces).text,
          uf: @xml_data.xpath('//nfe:emit/nfe:enderEmit/nfe:UF', @namespaces).text
        }
      },
      destinatario: {
        cnpj: @xml_data.xpath('//nfe:dest/nfe:CNPJ', @namespaces).text,
        nome: @xml_data.xpath('//nfe:dest/nfe:xNome', @namespaces).text,
        endereco: {
          rua: @xml_data.xpath('//nfe:dest/nfe:enderDest/nfe:xLgr', @namespaces).text,
          numero: @xml_data.xpath('//nfe:dest/nfe:enderDest/nfe:nro', @namespaces).text,
          bairro: @xml_data.xpath('//nfe:dest/nfe:enderDest/nfe:xBairro', @namespaces).text,
          cidade: @xml_data.xpath('//nfe:dest/nfe:enderDest/nfe:xMun', @namespaces).text,
          uf: @xml_data.xpath('//nfe:dest/nfe:enderDest/nfe:UF', @namespaces).text
        }
      }
    )
  end

  def create_products(fiscal_document)
    @xml_data.xpath('//nfe:det', @namespaces).each do |product_node|
      fiscal_document.products.create(
        name: product_node.xpath('nfe:prod/nfe:xProd', @namespaces).text,
        ncm: product_node.xpath('nfe:prod/nfe:NCM', @namespaces).text,
        cfop: product_node.xpath('nfe:prod/nfe:CFOP', @namespaces).text,
        unit: product_node.xpath('nfe:prod/nfe:uCom', @namespaces).text,
        quantity: product_node.xpath('nfe:prod/nfe:qCom', @namespaces).text.to_d,
        value: product_node.xpath('nfe:prod/nfe:vProd', @namespaces).text.to_d
      )
    end
  end

  def create_taxes(fiscal_document)
    fiscal_document.taxes.create(
      icms: @xml_data.xpath('//nfe:ICMS00/nfe:vICMS', @namespaces).text.to_d,
      ipi: @xml_data.xpath('//nfe:IPITrib/nfe:vIPI', @namespaces).text.to_d,
      pis: @xml_data.xpath('//nfe:PISNT/nfe:vPIS', @namespaces).text.to_d,
      cofins: @xml_data.xpath('//nfe:COFINSNT/nfe:vCOFINS', @namespaces).text.to_d
    )
  end
end
