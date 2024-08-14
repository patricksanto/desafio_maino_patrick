class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new; end

  def create
    uploaded_file = params[:report][:file]
    service = XmlProcessorService.new(uploaded_file)
    fiscal_document = service.call

    redirect_to report_path(fiscal_document), notice: 'Relatório gerado com sucesso.'
  end

  def show
    @fiscal_document = FiscalDocument.find(params[:id])
    @products = @fiscal_document.products
    @tax = @fiscal_document.taxes.first
  end

  private

  def document_params
    params.require(:report).permit(:file)
  end
end
