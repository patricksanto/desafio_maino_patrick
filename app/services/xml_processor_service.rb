class XmlProcessorService
  def initialize(file_content, zip_file: false)
    @file_content = file_content
    @zip_file = zip_file
    @namespaces = { 'nfe' => 'http://www.portalfiscal.inf.br/nfe' }
  end

  def call
    if @zip_file
      process_zip_file
    else
      [extract_data_from_xml(@file_content)]
    end
  end

  private

  def process_zip_file
    buffer = StringIO.new(@file_content)
    extracted_data = []

    Zip::File.open_buffer(buffer) do |zip_file|
      zip_file.each do |entry|
        next unless valid_xml_entry?(entry)

        entry.get_input_stream do |xml_file|
          extracted_data << extract_data_from_xml(xml_file.read)
        end
      end
    end

    extracted_data
  end

  def valid_xml_entry?(entry)
    !entry.name.start_with?('__MACOSX', '._') && entry.name.downcase.end_with?('.xml')
  end

  def extract_data_from_xml(content)
    return if content.strip.empty?

    xml_data = Nokogiri::XML(content)

    {
      fiscal_document: {
        serie: extract_text(xml_data, '//nfe:ide/nfe:serie'),
        nNF: extract_text(xml_data, '//nfe:ide/nfe:nNF'),
        dhEmi: extract_text(xml_data, '//nfe:ide/nfe:dhEmi'),
        emitente: extract_emitente_data(xml_data),
        destinatario: extract_destinatario_data(xml_data)
      },
      products: extract_products(xml_data),
      taxes: extract_taxes(xml_data)
    }
  end

  def extract_products(xml_data)
    xml_data.xpath('//nfe:det', @namespaces).map do |product_node|
      {
        name: product_node.xpath('nfe:prod/nfe:xProd', @namespaces).text,
        ncm: product_node.xpath('nfe:prod/nfe:NCM', @namespaces).text,
        cfop: product_node.xpath('nfe:prod/nfe:CFOP', @namespaces).text,
        unit: product_node.xpath('nfe:prod/nfe:uCom', @namespaces).text,
        quantity: product_node.xpath('nfe:prod/nfe:qCom', @namespaces).text.to_d,
        value: product_node.xpath('nfe:prod/nfe:vProd', @namespaces).text.to_d
      }
    end
  end

  def extract_taxes(xml_data)
    {
      icms: extract_decimal(xml_data, '//nfe:ICMS00/nfe:vICMS'),
      ipi: extract_decimal(xml_data, '//nfe:IPITrib/nfe:vIPI'),
      pis: extract_decimal(xml_data, '//nfe:PISNT/nfe:vPIS'),
      cofins: extract_decimal(xml_data, '//nfe:COFINSNT/nfe:vCOFINS')
    }
  end

  def extract_emitente_data(xml_data)
    {
      cnpj: extract_text(xml_data, '//nfe:emit/nfe:CNPJ'),
      nome: extract_text(xml_data, '//nfe:emit/nfe:xNome'),
      endereco: extract_endereco_data(xml_data, '//nfe:emit/nfe:enderEmit')
    }
  end

  def extract_destinatario_data(xml_data)
    {
      cnpj: extract_text(xml_data, '//nfe:dest/nfe:CNPJ'),
      nome: extract_text(xml_data, '//nfe:dest/nfe:xNome'),
      endereco: extract_endereco_data(xml_data, '//nfe:dest/nfe:enderDest')
    }
  end

  def extract_endereco_data(xml_data, base_path)
    {
      rua: extract_text(xml_data, "#{base_path}/nfe:xLgr"),
      numero: extract_text(xml_data, "#{base_path}/nfe:nro"),
      bairro: extract_text(xml_data, "#{base_path}/nfe:xBairro"),
      cidade: extract_text(xml_data, "#{base_path}/nfe:xMun"),
      uf: extract_text(xml_data, "#{base_path}/nfe:UF")
    }
  end

  def extract_text(xml_data, xpath)
    xml_data.xpath(xpath, @namespaces).text
  end

  def extract_decimal(xml_data, xpath)
    xml_data.xpath(xpath, @namespaces).text.to_d
  end
end
