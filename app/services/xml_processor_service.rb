require 'zip'

class XmlProcessorService
  def initialize(file_content, zip_file: false)
    @file_content = file_content
    @zip_file = zip_file
    @namespaces = { 'nfe' => 'http://www.portalfiscal.inf.br/nfe' }
  end

  def call
    if zip_file?
      process_zip_file
    else
      process_xml(@file.read)
    end
  end

  private

  def zip_file?
    File.extname(@file.path) == '.zip'
  end

  def valid_xml_entry?(entry)
    !entry.name.start_with?('__MACOSX', '._') && entry.name.downcase.end_with?('.xml')
  end

  def process_zip_file
    buffer = StringIO.new(@file_content)
    Zip::File.open(buffer) do |zip_file|
      zip_file.each do |entry|
        next unless valid_xml_entry?(entry)

        entry.get_input_stream do |xml_file|
          process_xml(xml_file.read)
        end
      end
    end
  end

  def process_xml(content)
    return if content.strip.empty?

    @xml_data = Nokogiri::XML(content)
    fiscal_document = create_fiscal_document
    create_products(fiscal_document)
    create_taxes(fiscal_document)
  rescue Nokogiri::XML::SyntaxError => e
    puts "Error processing XML: #{e.message}"
  end


  def create_fiscal_document
    FiscalDocument.create(
      serie: extract_text('//nfe:ide/nfe:serie'),
      nNF: extract_text('//nfe:ide/nfe:nNF'),
      dhEmi: extract_text('//nfe:ide/nfe:dhEmi'),
      emitente: extract_emitente_data,
      destinatario: extract_destinatario_data
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
      icms: extract_decimal('//nfe:ICMS00/nfe:vICMS'),
      ipi: extract_decimal('//nfe:IPITrib/nfe:vIPI'),
      pis: extract_decimal('//nfe:PISNT/nfe:vPIS'),
      cofins: extract_decimal('//nfe:COFINSNT/nfe:vCOFINS')
    )
  end

  def extract_emitente_data
    {
      cnpj: extract_text('//nfe:emit/nfe:CNPJ'),
      nome: extract_text('//nfe:emit/nfe:xNome'),
      endereco: extract_endereco_data('//nfe:emit/nfe:enderEmit')
    }
  end

  def extract_destinatario_data
    {
      cnpj: extract_text('//nfe:dest/nfe:CNPJ'),
      nome: extract_text('//nfe:dest/nfe:xNome'),
      endereco: extract_endereco_data('//nfe:dest/nfe:enderDest')
    }
  end

  def extract_endereco_data(base_path)
    {
      rua: extract_text("#{base_path}/nfe:xLgr"),
      numero: extract_text("#{base_path}/nfe:nro"),
      bairro: extract_text("#{base_path}/nfe:xBairro"),
      cidade: extract_text("#{base_path}/nfe:xMun"),
      uf: extract_text("#{base_path}/nfe:UF")
    }
  end

  def extract_text(xpath)
    @xml_data.xpath(xpath, @namespaces).text
  end

  def extract_decimal(xpath)
    @xml_data.xpath(xpath, @namespaces).text.to_d
  end
end
