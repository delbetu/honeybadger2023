class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string "record_type"
      t.string "message_type" # type is a restricted word. Used only with STI.
      t.integer "type_code"
      t.string "name"
      t.string "tag"
      t.string "message_stream"
      t.text "description"
      t.string "email"
      t.string "from"
      t.datetime "bounced_at"
      t.timestamps
    end
  end
end
