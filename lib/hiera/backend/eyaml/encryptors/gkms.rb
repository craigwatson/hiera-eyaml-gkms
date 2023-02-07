# frozen_string_literal: true

require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/encryptors/gkms/version'

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
            }
          }

          def self.encrypt(plaintext)
            enc_plaintext = Base64.encode64(plaintext)
            project = option :project
            location = option :location
            key_ring = option :keyring
            crypto_key = option :crypto_key
            encrypted = `echo "#{enc_plaintext}" | gcloud kms encrypt --location #{location} --keyring #{key_ring} --key #{crypto_key} --project #{project} --plaintext-file - --ciphertext-file -`
          end

          def self.decrypt(ciphertext)
            project = option :project
            location = option :location
            key_ring = option :keyring
            crypto_key = option :crypto_key

            decryptor = Encryptor.find "Gkms"
            ciphertext = decryptor.encode(ciphertext)
            shell_response = `echo #{ciphertext} | base64 -d | gcloud kms decrypt --location #{location} --keyring #{key_ring} --key #{crypto_key} --project #{project} --plaintext-file - --ciphertext-file -`
            Base64.decode64(shell_response)
          end
        end
      end
    end
  end
end
