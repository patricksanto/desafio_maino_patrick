class FiscalDocumentFilterService
  def initialize(params)
    @params = params
  end

  def filter
    documents = FiscalDocument.all
    documents = documents.where(serie: @params[:serie]) if @params[:serie].present?
    documents = documents.where(nNF: @params[:nNF]) if @params[:nNF].present?
    documents = documents.where("emitente->>'nome' = ?", @params[:emitente_nome]) if @params[:emitente_nome].present?
    documents = documents.where("destinatario->>'nome' = ?", @params[:destinatario_nome]) if @params[:destinatario_nome].present?
    documents = documents.where(dhEmi: date_range(@params[:dhEmi])) if @params[:dhEmi].present?
    documents
  end

  def series
    distinct_values(:serie)
  end

  def nf_numbers
    distinct_values(:nNF)
  end

  def emitente_names
    distinct_jsonb_values('emitente', 'nome')
  end

  def destinatario_names
    distinct_jsonb_values('destinatario', 'nome')
  end

  def datas_emissao
    distinct_dates(:dhEmi)
  end

  private

  def distinct_values(attribute)
    FiscalDocument.distinct.pluck(attribute)
  end

  def distinct_jsonb_values(jsonb_column, jsonb_field)
    field = Arel.sql("#{jsonb_column}->>'#{jsonb_field}'")
    FiscalDocument.distinct.pluck(field)
  end

  def distinct_dates(attribute)
    FiscalDocument.distinct.pluck(attribute).map(&:to_date).uniq
  end

  def date_range(date)
    Date.parse(date).beginning_of_day..Date.parse(date).end_of_day
  end
end
