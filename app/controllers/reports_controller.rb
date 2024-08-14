class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new; end

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

  private

  def document_params
    params.require(:report).permit(:file)
  end
end
