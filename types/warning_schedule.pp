# @summary Type of warning schedule, used for -M option of devicescan
#
# @see https://linux.die.net/man/5/smartd.conf
#
type Smartd::Warning_schedule = Enum['daily', 'once', 'diminishing', 'exec']
