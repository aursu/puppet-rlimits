# @summary Control resource limits environment
#
# Control resource limits environment
#
# @example
#   include rlimits
#
# @param manage_folder
#   Whether to control or not folder /etc/security/limits.d
#
# @param purge_folder
#   Set flag purge on /etc/security/limits.d file resource to cleanup
#   unmanaged files
#
# @param vendor_settings
#   Setup or not vendors default preset of ulimits (valid for CentOS)
#
class rlimits (
  Boolean $manage_folder   = true,
  Boolean $purge_folder    = false,
  Boolean $vendor_settings = true,
) {
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
    if $facts['os']['family'] == 'RedHat' {
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
