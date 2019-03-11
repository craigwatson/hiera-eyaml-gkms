begin
  require 'google/cloud/kms'
rescue LoadError
  fail "hiera-eyaml-gkms requires the 'google-cloud-kms' gem"
end

require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      module Encryptors
        class Gkms < Encryptor

          self.tag     = "GKMS"
          self.options = {
            :project => {
              :desc    => "GCP Project",
              :type    => :string,
              :default => ""
            },
            :location => {
              :desc    => "GCP Region of the KMS Keyring",
              :type    => :string,
              :default => "europe-west1"
            },
            :keyring => {
              :desc    => "GCP KMS Keyring name",
              :type    => :string,
              :default => ""
            },
            :crypto_key => {
              :desc    => "GCP KMS Crypto Key name",
              :type    => :string,
              :default => ""
            },
            :auth_type => {
              :desc    => "Authentication type for GCP SDK",
              :type    => :string,
              :default => "serviceaccount"
            },
            :credentials => {
              :desc    => "GCP Service Account credentials",
              :type    => :string,
              :default => ""
            },
          }

          def self.kms_client
            auth_type = self.option :auth_type

            if auth_type == "serviceaccount"
              credentials = self.option :credentials
              raise StandardError, "gkms_credentials is not defined" unless credentials
              client_opts = { version: 'v1', credentials: credentials }
            else
              client_opts = { version: 'v1' }
            end

            return Google::Cloud::Kms.new(client_opts)
          end

          def self.key_path
            project     = self.option :project
            location    = self.option :location
            keyring     = self.option :keyring
            crypto_key  = self.option :crypto_key

            raise StandardError, "gkms_project is not defined" unless project
            raise StandardError, "gkms_keyring is not defined" unless keyring
            raise StandardError, "gkms_crypto_key is not defined" unless crypto_key

            return Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path(project, location, keyring, crypto_key)
          end

          def self.encrypt plaintext
            kms_client = self.kms_client
            key_path = self.key_path
            kms_client.encrypt(key_path, plaintext).ciphertext
          end

          def self.decrypt ciphertext
            kms_client = self.kms_client
            key_path = self.key_path
            kms_client.decrypt(key_path, ciphertext).plaintext
          end
        end
      end
    end
  end
end
