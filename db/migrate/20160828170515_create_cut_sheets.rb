class CreateCutSheets < ActiveRecord::Migration[5.0]
  def change
    create_table :cut_sheets do |t|
      t.integer :job_id, null: false
      t.integer :fixture_id, null: false
      t.string :fixture_type, null: false
      t.string :description, null: false
      t.string :manufacturer, null: false
      t.text :notes, null: false
      t.string :pdf_url, null: false
    end
  end
end
