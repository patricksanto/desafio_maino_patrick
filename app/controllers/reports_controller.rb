class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new; end

  def create
    uploaded_file = params[:report][:file]
    # TODO ler xml com nokogiri ou outra gem

    # TODO processar o arquivo XML

    redirect_to report_path(fiscal_document), notice: 'Relatório gerado com sucesso.'
  end

  def show
    @fiscal_document = FiscalDocument.find(params[:id])
    @products = @fiscal_document.products
    @taxes = @fiscal_document.tax
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end
end
