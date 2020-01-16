# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include rlimits
class rlimits (
  Boolean $manage_folder   = true,
  Boolean $purge_folder    = false,
  Boolean $vendor_settings = true,
)
{
  if $manage_folder {
    file { '/etc/security/limits.d':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      force   => true,
      purge   => $purge_folder,
      recurse => true,
    }
    File['/etc/security/limits.d'] ~> Rlimit <| |>
  }

  if $vendor_settings {
    if $::osfamily == 'RedHat' {
      # Default limit for number of user's processes to prevent
      # accidental fork bombs.
      # See rhbz #432903 for reasoning.

      rlimit { '*/nproc/soft':
        ensure => present,
        value  => 4096,
      }

      rlimit { 'root/nproc/soft':
        ensure => present,
      }
    }
  }
}
