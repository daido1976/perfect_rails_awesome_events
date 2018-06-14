class CreateTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :tickets do |t|
      t.references :user, foreign_key: true
      t.references :event, foreign_key: true, null: false
      t.string :comment

      t.timestamps
    end

    add_index :tickets, [:user_id, :event_id], unique: true
    add_index :tickets, [:event_id, :user_id], unique: true
  end
end
