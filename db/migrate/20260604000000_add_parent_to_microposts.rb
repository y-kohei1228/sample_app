class AddParentToMicroposts < ActiveRecord::Migration[8.0]
  def change
    return if column_exists?(:microposts, :parent_id)

    add_reference :microposts, :parent, foreign_key: { to_table: :microposts }, index: true
  end
end
