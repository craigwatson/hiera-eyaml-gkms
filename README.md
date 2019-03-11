# hiera-eyaml-google-kms

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
$ gem install hiera-eyaml-google-kms
```

Then see [hiera-eyaml documentation](https://github.com/voxpupuli/hiera-eyaml) for how to use the eyaml tool to encrypt and use the 'GKMS' encryption_type for values to be
encrypted with this plugin.


# Development

- Distributed under the terms of the Apache License v2.0 - see [LICENSE.txt](/LICENSE.txt) for details.
- Copyright 2019 [Craig Watson](http://github.com/craigwatson)
- This project has been heavily based on [hiera-eyaml-kms](https://github.com/adenot/hiera-eyaml-kms) by [Allan Denot](https://github.com/adenot)
