class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new; end

  def index
    return @fiscal_documents = FiscalDocument.all if params.empty?

    filter_service = FiscalDocumentFilterService.new(params)
    @fiscal_documents = filter_service.filter
    @series = filter_service.series
    @nf_numbers = filter_service.nf_numbers
    @emitente_nomes = filter_service.emitente_names
    @destinatario_nomes = filter_service.destinatario_names
    @datas_emissao = filter_service.datas_emissao

    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename=relatorio_fiscal.xlsx'
      }
    end
  end

  def create
    uploaded_file = fetch_uploaded_file

    return handle_missing_file unless uploaded_file_present?(uploaded_file)
    return handle_invalid_file_type unless valid_file_type?(uploaded_file)

    file_path = save_uploaded_file(uploaded_file)

    if uploaded_file.content_type == 'application/zip'
      return handle_invalid_zip_content unless valid_zip_content?(file_path)
    end

    process_file(file_path)
  end

  def show
    @fiscal_document = FiscalDocument.find(params[:id])
    @products = @fiscal_document.products
    @tax = @fiscal_document.taxes.first

    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=relatorio_fiscal_#{params[:id]}.xlsx"
      }
    end
  end

  def destroy
    FiscalDocument.find(params[:id]).destroy

    redirect_to reports_path, notice: 'Documento fiscal deletado.'
  end

  private

  def valid_file_type?(file)
    allowed_types = ['application/xml', 'text/xml', 'application/zip']
    allowed_types.include?(file.content_type)
  end

  def valid_zip_content?(file_path)
    require 'zip'
    valid = true
    Zip::File.open(file_path) do |zip_file|
      zip_file.each do |entry|
        unless entry.name.end_with?('.xml')
          valid = false
          break
        end
      end
    end
    valid
  end

  def fetch_uploaded_file
    params[:report]&.dig(:file)
  end

  def uploaded_file_present?(file)
    file.present?
  end

  def handle_missing_file
    flash.now[:alert] = 'Nenhum arquivo foi enviado. Por favor, selecione um arquivo XML ou ZIP.'
    render :new, status: :unprocessable_entity
  end

  def handle_invalid_file_type
    flash.now[:alert] = 'Tipo de arquivo inválido. Por favor, envie um arquivo XML ou ZIP.'
    render :new, status: :unprocessable_entity
  end

  def save_uploaded_file(file)
    file_path = Rails.root.join('tmp', file.original_filename)
    File.open(file_path, 'wb') do |f|
      f.write(file.read)
    end
    file_path
  end

  def handle_invalid_zip_content
    flash.now[:alert] = 'O arquivo ZIP contém arquivos que não são XML. Por favor, envie um ZIP apenas com arquivos XML.'
    render :new, status: :unprocessable_entity
  end

  def process_file(file_path)
    XmlProcessorJob.perform_async(file_path.to_s)
    redirect_to new_report_path, notice: 'Seu relatório está sendo gerado...'
  end
end
