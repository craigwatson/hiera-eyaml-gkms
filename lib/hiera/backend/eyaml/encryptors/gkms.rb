begin
  require 'google/cloud/kms'
rescue LoadError
  fail "hiera-eyaml-google-kms requires the 'google-cloud-kms' gem"
end

require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      module Encryptors

        class Gkms < Encryptor

          self.tag = "GKMS"
          self.options = {
            :gcp_project => {
              :desc => "GCP Project",
              :type => :string,
              :default => ""
            },
            :gcp_location => {
              :desc => "GCP Region of the KMS Keyring",
              :type => :string,
              :default => ""
            },
            :gcp_keyring => {
              :desc => "GCP KMS Keyring name",
              :type => :string,
              :default => ""
            },
            :gcp_crypto_key => {
              :desc => "GCP KMS Crypto Key name",
              :type => :string,
              :default => ""
            },
          }

          def self.encrypt plaintext
            project    = self.option :gcp_project
            location   = self.option :gcp_location
            keyring    = self.option :gcp_keyring
            crypto_key = self.option :gcp_crypto_key

            kms_client = Google::Cloud::Kms.new(version: :v1)
            key_path = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path(project, location, keyring, crypto_key)

            resp = kms_client.encrypt(key_path, plaintext)
            resp.ciphertext
          end

          def self.decrypt ciphertext
            project    = self.option :gcp_project
            location   = self.option :gcp_location
            keyring    = self.option :gcp_keyring
            crypto_key = self.option :gcp_crypto_key

            kms_client = Google::Cloud::Kms.new(version: :v1)
            key_path = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path(project, location, keyring, crypto_key)

            resp = kms_client.decrypt(key_path, ciphertext)
            resp.plaintext
          end
        end
      end
    end
  end
end
