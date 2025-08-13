class CreateAgentes < ActiveRecord::Migration[8.0]
  def change
    create_table :agentes do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.string :channels
      t.integer :status

      t.timestamps
    end
  end
end
