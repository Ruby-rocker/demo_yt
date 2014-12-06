class CreateAudioFiles < ActiveRecord::Migration
  def change
    create_table :audio_files do |t|
      t.references :tenant
      t.references :audible, polymorphic: true

      t.timestamps
    end
    add_attachment :audio_files, :record

    add_index :audio_files, :tenant_id
    add_index :audio_files, [:audible_id, :audible_type]
  end
end
