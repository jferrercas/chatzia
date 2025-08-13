class CreateConversacions < ActiveRecord::Migration[8.0]
  def change
    create_table :conversacions do |t|
      t.references :agente, null: false, foreign_key: true
      t.integer :duracion
      t.text :resumen

      t.timestamps
    end
  end
end
