class CreateMensajes < ActiveRecord::Migration[8.0]
  def change
    create_table :mensajes do |t|
      t.text :contenido
      t.references :conversacion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
