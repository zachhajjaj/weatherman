class CreateForecasts < ActiveRecord::Migration[7.1]
  def change
    create_table :forecasts do |t|
      t.string :zip_code, null: false
      t.decimal :temperature, null: false
      t.decimal :temp_min
      t.decimal :temp_max
      t.string :description
      t.string :icon
      t.decimal :latitude
      t.decimal :longitude
      t.string :address
      t.text :extended_forecast

      t.timestamps
    end

    add_index :forecasts, :zip_code
  end
end
