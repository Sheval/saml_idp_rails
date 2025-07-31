require "saml_idp"

module SamlIdpRails
  class SamlSpConfig < ApplicationRecord
    before_create :generate_uuid

    serialize :name_id_formats, JSON
    serialize :assertion_consumer_services, JSON
    serialize :single_logout_services, JSON
    serialize :contact_person, JSON
    serialize :saml_attributes, JSON

    def parsed_metadata
      metadata_attr = ::SamlIdp::IncomingMetadata.new(raw_metadata).to_h
      # TODO: Move this logic to GEM
      metadata_attr[:name_id_formats] = metadata_attr[:name_id_formats].to_a
      if raw_metadata.present?
        assign_attributes(metadata_attr.except(:unspecified_certificate))
        # When SP metadata contains a <KeyDescriptor> that is not specified as signing or encryption,
        # this method assigns the certificate to signing only.
        self.signing_certificate = metadata_attr[:unspecified_certificate] if metadata_attr[:unspecified_certificate].present?
        encoded_certificates
      end
      self
    end

    # SP metadata removes header and footer of the certificate
    # This method adds them back
    def encoded_certificates
      self.signing_certificate = format_with_pem(signing_certificate) if signing_certificate.present? && !pem_formatted?(signing_certificate)
      self.encryption_certificate = format_with_pem(encryption_certificate) if encryption_certificate.present? && !pem_formatted?(encryption_certificate)
    end

    private

    def generate_uuid
      self.uuid = SecureRandom.uuid
    end

    def pem_formatted?(cert)
      cert.scan(/(-----BEGIN CERTIFICATE-----)(.+?)(-----END CERTIFICATE-----)/m).any?
    end

    def format_with_pem(cert)
      "-----BEGIN CERTIFICATE-----\n#{cert.strip}\n-----END CERTIFICATE-----"
    end
  end
end
