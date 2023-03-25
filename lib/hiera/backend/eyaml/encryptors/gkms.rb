# frozen_string_literal: true

require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/encryptors/gkms/version'
require 'google/cloud/kms'
require 'google/cloud/kms/v1'

class Hiera
  module Backend
    module Eyaml
      module Encryptors
        # Google KMS plugin for hiera-eyaml
        class Gkms < Encryptor
          VERSION = ::Hiera::Backend::Eyaml::Encryptors::GkmsVersion::VERSION
          self.tag = 'GKMS'
          self.options = {
            project: {
              desc: 'GCP Project',
              type: :string
            },
            location: {
              desc: 'GCP Region of the KMS Keyring',
              type: :string,
              default: 'global'
            },
            keyring: {
              desc: 'GCP KMS Keyring name',
              type: :string
            },
            crypto_key: {
              desc: 'GCP KMS Crypto Key name',
              type: :string
            },
            auth_type: {
              desc: 'Authentication type for GCP SDK',
              type: :string,
              default: 'serviceaccount'
            },
            credentials: {
              desc: 'GCP Service Account credentials',
              type: :string
            },
            use_gcloud_cli: {
              desc: 'Use gcloud CLI to encrypt/decrypt secrets',
              type: :bool,
              default: false
            }
          }

          def self.kms_client
            auth_type = option :auth_type

            if auth_type == 'serviceaccount'
              credentials = option :credentials
              raise StandardError, 'gkms_credentials is not defined' unless credentials

              Google::Cloud::Kms.configure do |config|
                config.credentials = credentials
                config.timeout = 10.0
              end
            else
              ENV['GOOGLE_AUTH_SUPPRESS_CREDENTIALS_WARNINGS'] = '1'
            end

            ::Google::Cloud::Kms.key_management_service
          end

          def self.key_path
            project = option :project
            location = option :location
            key_ring = option :keyring
            crypto_key = option :crypto_key

            raise StandardError, 'gkms_project is not defined' unless project
            raise StandardError, 'gkms_keyring is not defined' unless key_ring
            raise StandardError, 'gkms_crypto_key is not defined' unless crypto_key

            kms_client.crypto_key_path project: project,
                                       location: location,
                                       key_ring: key_ring,
                                       crypto_key: crypto_key
          end

          def self.encrypt(plaintext)
            use_gcloud_cli = option :use_gcloud_cli
            if use_gcloud_cli
              enc_plaintext = Base64.encode64(plaintext)
              project = option :project
              location = option :location
              key_ring = option :keyring
              crypto_key = option :crypto_key
              `echo "#{enc_plaintext}" | gcloud kms encrypt --location #{location} --keyring #{key_ring} --key #{crypto_key} --project #{project} --plaintext-file - --ciphertext-file -`
            else
              kms_client.encrypt(name: key_path, plaintext: plaintext).ciphertext
            end
          end

          def self.decrypt(ciphertext)
            use_gcloud_cli = option :use_gcloud_cli
            if use_gcloud_cli
              project = option :project
              location = option :location
              key_ring = option :keyring
              crypto_key = option :crypto_key

              decryptor = Encryptor.find 'Gkms'
              ciphertext = decryptor.encode(ciphertext)
              response = `echo #{ciphertext} | base64 -d | gcloud kms decrypt --location #{location} --keyring #{key_ring} --key #{crypto_key} --project #{project} --plaintext-file - --ciphertext-file -`
              Base64.decode64(response)
            else
              kms_client.decrypt(name: key_path, ciphertext: ciphertext).plaintext
            end
          end
        end
      end
    end
  end
end
