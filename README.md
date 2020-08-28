# rlimits

Control configuration files for the pam_limits module (see man 5 limits.conf)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with rlimits](#setup)
    * [What rlimits affects](#what-rlimits-affects)
    * [Beginning with rlimits](#beginning-with-rlimits)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference](#reference)

## Description

The `pam_limits.so` module applies `ulimit` limits, nice priority and number of
simultaneous login sessions limit to user login sessions. This description of
the configuration file syntax applies to the `/etc/security/limits.conf` file
and `*.conf` files in the `/etc/security/limits.d` directory.

The syntax of the lines is as follows:

```
<domain><type><item><value>
```

## Setup

### What rlimits affects **OPTIONAL**

rlimits affects only `*.conf` files in the `/etc/security/limits.d`

### Beginning with rlimits

To use this module it is enough to include it into catalog

```
include rlimits
```

## Usage

```
   rlimit { '*/nproc/soft':
     ensure => present,
     value  => 4096,
   }

   rlimit { 'root/nproc/soft':
     ensure => present,
   }
```

## Reference

See REFERENCE.md for reference
