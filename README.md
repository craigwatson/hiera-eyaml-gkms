# hiera-eyaml-gkms

[![Build Status](https://secure.travis-ci.org/craigwatson/hiera-eyaml-gkms.svg?branch=master)](http://travis-ci.org/craigwatson/hiera-eyaml-gkms)
[![Gem Version](https://img.shields.io/gem/v/hiera-eyaml-gkms.svg)](https://rubygems.org/gems/hiera-eyaml-gkms)
[![Gem Downloads](https://img.shields.io/gem/dt/hiera-eyaml-gkms.svg)](https://rubygems.org/gems/hiera-eyaml-gkms)

This is a plugin encryptor for the [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml) project, which encrypts and decrypts Hiera data using Google Cloud KMS, based on [hiera-eyaml-kms](https://github.com/adenot/hiera-eyaml-kms) by [Allan Denot](https://github.com/adenot).

[Google Cloud KMS](https://cloud.google.com/kms) is a service that encrypts and decrypts data through API calls. Permissions are controlled by IAM.

Using KMS avoids having to expose private keys to decrypt information when running Puppet.

# Requirements

The Google Cloud Ruby SDK and the `hiera-eyaml` Gem are dependencies:

```
$ gem install hiera-eyaml google-cloud-kms
```

# Installation

```
$ gem install hiera-eyaml-gkms
```

Then see [hiera-eyaml documentation](https://github.com/voxpupuli/hiera-eyaml) for how to use the eyaml tool to encrypt and use the 'GKMS' encryption_type for values to be
encrypted with this plugin.

## Configuration

This plugin adds several options to `hiera-eyaml`:

```
--gkms-project      Required: GCP Project
--gkms-keyring      Required: Google Cloud KMS Keyring
--gkms-crypto-key   Required: Google Cloud KMS Key
--gkms-location     Google Cloud KMS Keyring location (default: europe-west1)
--gkms-auth-type    Authentication type for Google API (default: serviceaccount)
--gkms-credentials  Path to service account JSON file (Required when using serviceaccount authentication type)
```

The minimum configuration required is the GCP project, keyring and crypto-key to use. If using a service account, you will also need to point the plugin to the JSON file containing the service account key.

If using a configuration YAML file:

```
---
gkms_project: 'graphite-melon-123567'
gkms_auth_type: 'machineaccount'
gkms_location: 'europe-west1'
gkms_keyring: 'keyring'
gkms_crypto_key: 'puppet_eyaml'
```

## Usage with Google Compute Engine

The plugin can also be run using Google Compute Engine's service account by passing `--gke-auth-type=machineaccount`, and will need to be configured with the following IAM permissions:

- Authentication scope: https://www.googleapis.com/auth/cloudkms
- IAM role: `roles/cloudkms.cryptoKeyEncrypterDecrypter`

## Terraform Example

```
resource "google_kms_key_ring" "keyring" {
  name     = "keyring"
  location = "europe-west1"
}

resource "google_kms_crypto_key" "puppet_eyaml" {
  name     = "puppet_eyaml"
  key_ring = "${google_kms_key_ring.keyring.self_link}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_member" "eyaml" {
  crypto_key_id = "${google_kms_crypto_key.puppet_eyaml.self_link}"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

resource "google_compute_instance_template" "template" {
  ...

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloudkms"]
  }

  ...
}
```

# Development

- Distributed under the terms of the Apache License v2.0 - see [LICENSE.txt](/LICENSE.txt) for details.
- Copyright 2019 [Craig Watson](http://github.com/craigwatson)
- This project has been heavily based on [hiera-eyaml-kms](https://github.com/adenot/hiera-eyaml-kms) by [Allan Denot](https://github.com/adenot)
