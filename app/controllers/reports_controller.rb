class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new; end

  def index
    return @fiscal_documents = FiscalDocument.all if params.empty?

    filter_service = FiscalDocumentFilterService.new(params)
    @fiscal_documents = filter_service.filter
    @series = filter_service.series
    @nf_numbers = filter_service.nf_numbers
    @emitente_nomes = filter_service.emitente_nomes
    @datas_emissao = filter_service.datas_emissao
  end

  def create
    uploaded_file = params[:report][:file]

    file_path = Rails.root.join('tmp', uploaded_file.original_filename)
    File.open(file_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end

    XmlProcessorJob.perform_async(file_path.to_s)

    redirect_to new_report_path, notice: 'Seu relatório esta sendo gerado...'
  end

  def show
    @fiscal_document = FiscalDocument.find(params[:id])
    @products = @fiscal_document.products
    @tax = @fiscal_document.taxes.first
  end

  def destroy
    FiscalDocument.find(params[:id]).destroy

    redirect_to reports_path, notice: 'Documento fiscal deletado.'
  end

  private

  def document_params
    params.require(:report).permit(:file)
  end
end
