class AddGradingColumns < ActiveRecord::Migration
  def change
    add_column :assignments, :points_possible, :float
    add_column :responses, :score, :float, :null => true, :default => nil
  end
end
