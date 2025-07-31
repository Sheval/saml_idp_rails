class CreateSamlIdpRailsSamlSpConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :saml_idp_rails_saml_sp_configs do |t|
      # For identification
      t.string :name
      t.string :display_name
      # SP attributes
      t.string :entity_id
      t.string :signing_certificate
      t.string :encryption_certificate
      t.boolean :sign_assertions
      t.boolean :sign_authn_request
      # IdP attributes
      t.string :certificate
      t.string :private_key
      t.string :pv_key_password
      t.string :relay_state
      t.string :name_id_attribute
      t.text :raw_metadata

      # SP attributes
      t.text :name_id_formats, default: '[]'
      t.text :assertion_consumer_services, default: '[]'
      t.text :single_logout_services, default: '{}'
      # IdP attributes
      t.text :contact_person, default: '{}'
      t.text :saml_attributes, default: '{}'

      # Public UUID for SP
      t.string :uuid, null: false

      t.timestamps
    end

    add_index :saml_idp_rails_saml_sp_configs, :name, unique: true
    add_index :saml_idp_rails_saml_sp_configs, :entity_id, unique: true
  end
end
