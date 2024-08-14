class XmlProcessorJob
  include Sidekiq::Job

  def perform(file_path)
    file = File.open(file_path)
    service = XmlProcessorService.new(file)
    service.call
    file.close
    File.delete(file_path) if File.exist?(file_path)
  end
end
