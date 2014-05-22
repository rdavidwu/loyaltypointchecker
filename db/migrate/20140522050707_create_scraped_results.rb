class CreateScrapedResults < ActiveRecord::Migration
  def change
    create_table :scraped_results do |t|
      t.string :status
      t.text :result

      t.timestamps
    end
  end
end
