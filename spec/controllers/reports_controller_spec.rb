require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:zip_file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.zip'), 'application/zip') }
  let(:pdf_file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.pdf'), 'application/pdf') }
  let(:xml_file_1) { fixture_file_upload(Rails.root.join('spec/fixtures/files/CASE_001.xml'), 'text/xml') }
  let(:xml_file_2) { fixture_file_upload(Rails.root.join('spec/fixtures/files/CASE_002.xml'), 'text/xml') }


  before do
    sign_in user
    ActiveJob::Base.queue_adapter = :inline
  end

  describe 'POST #create' do
    context 'with valid file upload' do
      let(:xml_file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.xml'), 'text/xml') }

      it 'enqueues an XML processor job' do
        expect {
          post :create, params: { report: { file: xml_file } }
        }.to change { XmlProcessorJob.jobs.size }.by(1)
      end
    end

    context 'without a file upload' do
      it 'renders the new template with an error' do
        post :create, params: { report: { file: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq('Nenhum arquivo foi enviado. Por favor, selecione um arquivo XML ou ZIP.')
      end
    end

    context 'with invalid file type (PDF)' do
      it 'does not enqueue any job and renders the new template with an error' do
        expect {
          post :create, params: { report: { file: pdf_file } }
        }.not_to change { XmlProcessorJob.jobs.size }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq('Tipo de arquivo inválido. Por favor, envie um arquivo XML ou ZIP.')
      end
    end

    context 'with a valid ZIP file containing multiple XMLs' do
      let(:zip_file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.zip'), 'application/zip') }

      it 'enqueues an XML processor job for each XML file in the ZIP' do
        expect {
          post :create, params: { report: { file: zip_file } }
        }.to change { XmlProcessorJob.jobs.size }.by(1)

        expect(response).to redirect_to(new_report_path)
        expect(flash[:notice]).to eq('Seu relatório está sendo gerado...')
      end

      it 'enqueues an XML processor job for the ZIP file' do
        expect {
          post :create, params: { report: { file: zip_file } }
        }.to change { XmlProcessorJob.jobs.size }.by(1)
      end

      it 'processes the ZIP file and creates two fiscal documents' do
        Sidekiq::Testing.inline! do
          expect {
            post :create, params: { report: { file: zip_file } }
          }.to change { FiscalDocument.count }.by(2)
        end
      end
    end

    describe 'GET #index' do
      it 'returns a successful response' do
        get :index
        expect(response).to be_successful
      end

      it 'filters reports based on the provided parameters' do
        create(:fiscal_document, serie: '123')
        create(:fiscal_document, serie: '456')

        get :index, params: { serie: '123' }
        expect(assigns(:fiscal_documents).count).to eq(1)
        expect(assigns(:fiscal_documents).first.serie).to eq('123')
      end
    end

    describe 'DELETE #destroy' do
      let!(:fiscal_document) { create(:fiscal_document) }

      it 'deletes the fiscal document' do
        expect {
          delete :destroy, params: { id: fiscal_document.id }
        }.to change(FiscalDocument, :count).by(-1)
        expect(response).to redirect_to(reports_path)
        expect(flash[:notice]).to eq('Documento fiscal deletado.')
      end
    end

    describe 'GET #show' do
      let!(:fiscal_document) { create(:fiscal_document) }

      it 'returns a successful response and assigns the fiscal document' do
        get :show, params: { id: fiscal_document.id }
        expect(response).to be_successful
        expect(assigns(:fiscal_document)).to eq(fiscal_document)
      end
    end

  end
end
