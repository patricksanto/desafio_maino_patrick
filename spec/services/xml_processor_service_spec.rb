require 'rails_helper'

RSpec.describe XmlProcessorService, type: :service do
  let(:zip_file_path) { Rails.root.join('spec/fixtures/files/sample.zip') }
  let(:service) { XmlProcessorService.new(File.open(zip_file_path)) }

  it 'processes each XML file in the ZIP' do
    expect {
      service.call
    }.to change { FiscalDocument.count }.by(2)
  end
end
