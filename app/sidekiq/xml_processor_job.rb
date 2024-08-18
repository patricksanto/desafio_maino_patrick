class XmlProcessorJob
  include Sidekiq::Job

  def perform(file_content, file_extension)
    if file_extension == '.zip'
      service = XmlProcessorService.new(file_content, zip_file: true)
    else
      service = XmlProcessorService.new(file_content, zip_file: false)
    end
    service.call
  end
end
