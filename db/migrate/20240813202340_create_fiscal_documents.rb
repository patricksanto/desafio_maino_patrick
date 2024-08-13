class CreateFiscalDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :fiscal_documents do |t|
      t.string :serie
      t.string :nNF
      t.datetime :dhEmi
      t.jsonb :emitente
      t.jsonb :destinatario

      t.timestamps
    end
  end
end
