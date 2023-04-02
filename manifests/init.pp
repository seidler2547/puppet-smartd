# smartd/manifests/init.pp
#
# - Copyright (C) 2012 MIT Computer Science & Artificial Intelligence Laboratory
# - Copyright (C) 2013-2015 Joshua Hoblitt <jhoblitt@cpan.org>
# - Copyright (C) 2015-2023 Gabriel Filion <gabster@lelutin.ca>
#
# @summary Manage the smartmontools package including the smartd daemon
#
# @example basic usage
#   class { 'smartd': }
#
# @param ensure
#   Standard Puppet ensure semantics (supports `purged` state if your
#   package provider does). Defaults to `present`. Valid values are:
#   `present`,`latest`,`absent`,`purged`
# @param package_name
#   Name of the smartmontools package.
# @param service_name
#   Name of the smartmontools monitoring daemon.
# @param service_ensure
#   State of the smartmontools monitoring daemon. Defaults to `running`. Valid
#   values are:
#   `running`,`stopped`
# @param manage_service
#   Set this to false to disable managing the smartmontools service.
#   This parameter is disregarded when $ensure = absent|purge.
# @param config_file
#   Path to the configuration file for the monitoring daemon.
# @param devicescan
#   Sets the `DEVICESCAN` directive in the smart daemon config file.  Tells the
#   smart daemon to automatically detect all of the SMART-capable drives in the
#   system. Defaults to`true`.
# @param devicescan_options
#   String of options to the `DEVICESCAN` directive. `devicescan` must equal true
#   for this to have any effect.
# @param devices
#   `Array` of `Hash`. Explicit list of raw block devices to check.  Eg.
#    [{ device => '/dev/sda', options => '-I 194' }]
# @param mail_to
#   Local username or email address used by smart daemon for notifcations.
#   Defaults to `root`
# @param warning_schedule
#   Smart daemon problem mail notification frequency. Defaults to `daily`.
#   Valid values are: `daily`,`once`,`diminishing`, `exec`
#   Note that if the value `exec` is used, then the parameter `exec_script`
#   *must* be specified.
# @param exec_script
#   Path to the script that should be executed if `warning_schedule` is set to
#   `exec`.
# @param enable_default
#   Set this to false to disable the `DEFAULT` directive in the `smartd.conf`
#   file. The `DEFAULT` directive was added in the 5.43 release of
#   smartmontools.
#   If this parameter is set to false, then the values from the `mail_to` and
#   `warning_schedule` parameters are set o nthe `DEVICESCAN` directive (if
#   enabled) instead of the (absent) `DEFAULT` directive.
# @param default_options
#   String of additional arguments to be set on the `DEFAULT` directive.
#   If `enable_default` is set to false, the value for this parameter will be
#   set on the `DEVICESCAN` directive (if enabled) instead of the (absent)
#   `DEFAULT` directive.
#
class smartd (
  $ensure             = 'present',
  $package_name       = $smartd::params::package_name,
  $service_name       = $smartd::params::service_name,
  $service_ensure     = $smartd::params::service_ensure,
  $manage_service     = $smartd::params::manage_service,
  $config_file        = $smartd::params::config_file,
  $devicescan         = $smartd::params::devicescan,
  $devicescan_options = $smartd::params::devicescan_options,
  $devices            = $smartd::params::devices,
  $mail_to            = $smartd::params::mail_to,
  $warning_schedule   = $smartd::params::warning_schedule,
  $exec_script        = $smartd::params::exec_script,
  $enable_default     = $smartd::params::enable_default,
  $default_options    = $smartd::params::default_options,
) inherits smartd::params {
  validate_re($ensure, '^present$|^latest$|^absent$|^purged$')
  validate_string($package_name)
  validate_string($service_name)
  validate_re($service_ensure, '^running$|^stopped$')
  validate_string($config_file)
  validate_bool($devicescan)
  validate_string($devicescan_options)
  validate_array($devices)
  validate_string($mail_to)
  validate_re($warning_schedule, '^daily$|^once$|^diminishing$|^exec$',
    '$warning_schedule must be either daily, once, diminishing, or exec.')
  if $warning_schedule == 'exec' {
    if $exec_script == false {
      fail('$exec_script must be set when $warning_schedule is set to exec.')
    }
    $real_warning_schedule = "${warning_schedule} ${exec_script}"
  }
  else {
    if $exec_script != false {
      fail('$exec_script should not be used when $warning_schedule is not set to exec.')
    }
    $real_warning_schedule = $warning_schedule
  }
  validate_bool($enable_default)
  validate_string($default_options)

  case $ensure {
    'present', 'latest': {
      $pkg_ensure  = $ensure
      $svc_ensure  = $service_ensure
      $svc_enable  = $service_ensure ? { 'running' => true, 'stopped' => false }
      $file_ensure = 'present'
      $srv_manage  = $manage_service
    }
    'absent', 'purged': {
      $pkg_ensure  = $ensure
      $svc_ensure  = 'stopped'
      $svc_enable  = false
      $file_ensure = 'absent'
      $srv_manage  = false
    }
    default: {
      fail("unsupported value of \$ensure: ${ensure}")
    }
  }

  ensure_packages([$package_name], { ensure => $pkg_ensure })

  if $srv_manage {
    service { $service_name:
      ensure     => $svc_ensure,
      enable     => $svc_enable,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => File[$config_file],
    }

    Package[$package_name] -> Service[$service_name]
  }

  file { $config_file:
    ensure  => $file_ensure,
    owner   => 'root',
    group   => $::gid,
    mode    => '0644',
    content => template('smartd/smartd.conf'),
    require => Package[$package_name],
  }

  # Special sauce for Debian where it's not enough for the rc script
  # to be enabled, it also needs its own extra special config file.
  if $::osfamily == 'Debian' {
    $debian_augeas_changes = $svc_enable ? {
      false   => 'remove start_smartd',
      default => 'set start_smartd "yes"',
    }

    augeas { 'shell_config_start_smartd':
      lens    => 'Shellvars.lns',
      incl    => '/etc/default/smartmontools',
      changes => $debian_augeas_changes,
      require => Package[$package_name],
    }
    if $srv_manage {
      Augeas['shell_config_start_smartd'] {
        before  => Service[$service_name],
      }
    }
  }
}
