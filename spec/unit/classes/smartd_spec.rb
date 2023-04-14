require 'spec_helper'

describe 'smartd', type: :class do
  shared_examples_for 'default' do |values|
    content = (values && values[:content]) ? values[:content] : ['DEFAULT -m root -M daily', 'DEVICESCAN']
    config_file = (values && values[:config_file]) ? values[:config_file] : '/etc/smartd.conf'
    group = (values && values[:group]) ? values[:group] : 0

    it { is_expected.to contain_package('smartmontools').with_ensure('installed') }

    it 'contains the configuration file with the parameters set appropriately' do
      expect(subject).to contain_file(config_file).with(
        ensure: 'present',
        owner: 'root',
        group: group,
        mode: '0644',
      )
    end

    it "contains File[#{config_file}] with correct contents" do
      verify_contents(catalogue, config_file, content)
    end
  end

  describe 'on a supported osfamily, default parameters' do
    describe 'for osfamily SuSE' do
      let(:facts) { { os: { family: 'SuSE' }, smartmontools_version: '5.43' } }

      it_behaves_like 'default', {}
      it { is_expected.not_to contain_augeas('shell_config_start_smartd') }
      it { is_expected.to contain_service('smartd').with_ensure('running').with_enable(true) }
      it { is_expected.to contain_service('smartd').with_subscribe('File[/etc/smartd.conf]') }
    end

    describe 'for osfamily RedHat' do
      describe 'for operatingsystem RedHat' do
        describe 'for operatingsystemmajrelease 6' do
          let(:facts) do
            {
              os: {
                family: 'RedHat',
                name: 'RedHat',
                release: {
                  major: '6',
                },
              },
              smartmontools_version: '5.43',
            }
          end

          it_behaves_like 'default', {}
          it { is_expected.not_to contain_augeas('shell_config_start_smartd') }
          it { is_expected.to contain_service('smartd').with_ensure('running').with_enable(true) }
          it { is_expected.to contain_service('smartd').with_subscribe('File[/etc/smartd.conf]') }
        end

        describe 'for operatingsystemmajrelease 7' do
          let(:facts) do
            {
              os: {
                family: 'RedHat',
                name: 'RedHat',
                release: {
                  major: '7',
                },
              },
              smartmontools_version: '6.2',
            }
          end

          it_behaves_like 'default', config_file: '/etc/smartmontools/smartd.conf'
          it { is_expected.not_to contain_augeas('shell_config_start_smartd') }
          it { is_expected.to contain_service('smartd').with_ensure('running').with_enable(true) }
          it { is_expected.to contain_service('smartd').with_subscribe('File[/etc/smartmontools/smartd.conf]') }
        end
      end

      describe 'for operatingsystem Fedora' do
        describe 'for operatingsystemrelease 18' do
          let(:facts) do
            {
              os: {
                family: 'RedHat',
                name: 'Fedora',
                release: {
                  major: '18',
                },
              },
              smartmontools_version: '5.43',
            }
          end

          it_behaves_like 'default', {}
          it { is_expected.not_to contain_augeas('shell_config_start_smartd') }
          it { is_expected.to contain_service('smartd').with_ensure('running').with_enable(true) }
          it { is_expected.to contain_service('smartd').with_subscribe('File[/etc/smartd.conf]') }
        end

        describe 'for operatingsystemrelease 19' do
          let(:facts) do
            {
              os: {
                family: 'RedHat',
                name: 'Fedora',
                release: {
                  major: '19',
                },
              },
              smartmontools_version: '6.1',
            }
          end

          it_behaves_like 'default', config_file: '/etc/smartmontools/smartd.conf'
          it { is_expected.not_to contain_augeas('shell_config_start_smartd') }
          it { is_expected.to contain_service('smartd').with_ensure('running').with_enable(true) }
          it { is_expected.to contain_service('smartd').with_subscribe('File[/etc/smartmontools/smartd.conf]') }
        end
      end
    end

    describe 'for osfamily Debian' do
      let(:facts) { { os: { family: 'Debian' }, smartmontools_version: '5.43' } }

      it_behaves_like 'default', {}
      it { is_expected.to contain_augeas('shell_config_start_smartd').with_changes('set start_smartd "yes"') }
      it { is_expected.to contain_service('smartmontools').with_ensure('running').with_enable(true) }
      it { is_expected.to contain_service('smartmontools').with_subscribe('File[/etc/smartd.conf]') }
    end

    describe 'for osfamily FreeBSD' do
      let(:facts) { { os: { family: 'FreeBSD' }, smartmontools_version: '5.43' } }

      it_behaves_like 'default', config_file: '/usr/local/etc/smartd.conf', group: 0
      it { is_expected.not_to contain_augeas('shell_config_start_smartd') }
      it { is_expected.to contain_service('smartd').with_ensure('running').with_enable(true) }
      it { is_expected.to contain_service('smartd').with_subscribe('File[/usr/local/etc/smartd.conf]') }
    end
  end

  describe 'on a supported osfamily, custom parameters' do
    describe 'for osfamily RedHat' do
      let(:facts) { { os: { family: 'RedHat' }, smartmontools_version: '5.43' } }

      describe 'ensure => present' do
        let(:params) { { ensure: 'present' } }

        it { is_expected.to contain_package('smartmontools').with_ensure('installed') }
        it { is_expected.to contain_service('smartd').with_ensure('running').with_enable(true) }
        it { is_expected.to contain_service('smartd').with_subscribe('File[/etc/smartd.conf]') }
      end

      describe 'ensure => latest' do
        let(:params) { { ensure: 'latest' } }

        it { is_expected.to contain_package('smartmontools').with_ensure('latest') }
        it { is_expected.to contain_service('smartd').with_ensure('running').with_enable(true) }
        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('present') }
      end

      describe 'ensure => absent' do
        let(:params) { { ensure: 'absent' } }

        it { is_expected.to contain_package('smartmontools').with_ensure('absent') }
        it { is_expected.not_to contain_service('smartd') }
        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('absent') }
      end

      describe 'ensure => purge' do
        let(:params) { { ensure: 'purged' } }

        it { is_expected.to contain_package('smartmontools').with_ensure('purged') }
        it { is_expected.not_to contain_service('smartd') }
        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('absent') }
      end

      describe 'service_ensure => running' do
        let(:params) { { service_ensure: 'running' } }

        it { is_expected.to contain_package('smartmontools').with_ensure('installed') }

        it { is_expected.to contain_service('smartd').with_ensure('running').with_enable(true) }
      end

      describe 'service_ensure => stopped' do
        let(:params) { { service_ensure: 'stopped' } }

        it { is_expected.to contain_package('smartmontools').with_ensure('installed') }

        it { is_expected.to contain_service('smartd').with_ensure('stopped').with_enable(false) }
      end

      describe 'manage_service => false' do
        let(:params) { { manage_service: false } }

        it { is_expected.not_to contain_service('smartd') }
      end

      describe 'devicescan =>' do
        context 'when using default value' do
          it do
            is_expected.to contain_file('/etc/smartd.conf')
              .with_ensure('present')
              .with_content(%r{^DEVICESCAN$})
          end
        end
        # default value

        context 'when true' do
          let(:params) { { devicescan: true } }

          it do
            is_expected.to contain_file('/etc/smartd.conf')
              .with_ensure('present')
              .with_content(%r{^DEVICESCAN$})
          end

          context 'with enable_default => false' do
            before(:each) do
              params[:enable_default] = false
            end

            it 'has the same arguments as DEFAULT would have' do
              is_expected.to contain_file('/etc/smartd.conf')
                .with_ensure('present')
                .with_content(%r{^DEVICESCAN -m root -M daily$})
            end
          end
        end
        # devicescan = true

        context 'when false' do
          let(:params) { { devicescan: false } }

          it do
            is_expected.to contain_file('/etc/smartd.conf')
              .with_ensure('present')
              .without_content(%r{^DEVICESCAN$})
          end
        end
        # devicescan = false
      end
      # devicescan

      describe 'devicescan_options => somevalue' do
        let(:params) { { devicescan_options: 'somevalue' } }

        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('present') }

        it 'contains file /etc/smartd.conf with contents ...' do
          verify_contents(catalogue, '/etc/smartd.conf', [
                            'DEFAULT -m root -M daily',
                            'DEVICESCAN somevalue'
                          ])
        end
      end

      describe 'devices without options' do
        let(:params) do
          {
            'devices' => [
              { 'device' => '/dev/sg1' },
              { 'device' => '/dev/sg2' }
            ],
          }
        end

        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('present') }

        it 'contains file /etc/smartd.conf with contents ...' do
          verify_contents(catalogue, '/etc/smartd.conf', [
                            'DEFAULT -m root -M daily',
                            '/dev/sg1',
                            '/dev/sg2'
                          ])
        end
      end

      describe 'devices with options"' do
        let :params do
          {
            'devices' => [
              { 'device' => '/dev/sg1', 'options' => '-o on -S on -a' },
              { 'device' => '/dev/sg2', 'options' => '-o on -S on -a' }
            ],
          }
        end

        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('present') }

        it 'contains file /etc/smartd.conf with contents ...' do
          verify_contents(catalogue, '/etc/smartd.conf', [
                            'DEFAULT -m root -M daily',
                            '/dev/sg1 -o on -S on -a',
                            '/dev/sg2 -o on -S on -a'
                          ])
        end
      end

      describe 'devices behind a cciss controller with options"' do
        let :params do
          {
            'devices' => [
              { 'device' => '/dev/cciss/c0d0', 'options' => '-d cciss,0 -a -o on -S on' },
              { 'device' => '/dev/cciss/c0d0', 'options' => '-d cciss,1 -a -o on -S on' },
              { 'device' => '/dev/cciss/c0d0', 'options' => '-d cciss,2 -a -o on -S on' },
              { 'device' => '/dev/cciss/c0d0', 'options' => '-d cciss,3 -a -o on -S on' },
              { 'device' => '/dev/cciss/c0d0', 'options' => '-d cciss,4 -a -o on -S on' },
              { 'device' => '/dev/cciss/c0d0', 'options' => '-d cciss,5 -a -o on -S on' }

            ],
          }
        end

        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('present') }

        it 'contains file /etc/smartd.conf with contents ...' do
          verify_contents(catalogue, '/etc/smartd.conf', [
                            'DEFAULT -m root -M daily',
                            '/dev/cciss/c0d0 -d cciss,0 -a -o on -S on',
                            '/dev/cciss/c0d0 -d cciss,1 -a -o on -S on',
                            '/dev/cciss/c0d0 -d cciss,2 -a -o on -S on',
                            '/dev/cciss/c0d0 -d cciss,3 -a -o on -S on',
                            '/dev/cciss/c0d0 -d cciss,4 -a -o on -S on',
                            '/dev/cciss/c0d0 -d cciss,5 -a -o on -S on'
                          ])
        end
      end

      describe 'mail_to => someguy@localdomain' do
        let(:params) { { mail_to: 'someguy@localdomain' } }

        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('present') }

        it 'contains file /etc/smartd.conf with contents ...' do
          verify_contents(catalogue, '/etc/smartd.conf', [
                            'DEFAULT -m someguy@localdomain -M daily'
                          ])
        end
      end

      describe 'warning_schedule => diminishing' do
        let(:params) { { warning_schedule: 'diminishing' } }

        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('present') }

        it 'contains file /etc/smartd.conf with contents ...' do
          verify_contents(catalogue, '/etc/smartd.conf', [
                            'DEFAULT -m root -M diminishing'
                          ])
        end
      end

      describe 'enable_default =>' do
        context 'when using default value' do
          context 'with fact smartmontool_version = "5.43"' do
            before(:each) do
              facts[:smartmontools_version] = '5.43'
            end

            it do
              is_expected.to contain_file('/etc/smartd.conf')
                .with_ensure('present')
                .with_content(%r{DEFAULT -m root -M daily})
            end
          end

          context 'with fact smartmontool_version = "5.42"' do
            before(:each) do
              facts[:smartmontools_version] = '5.42'
            end

            it do
              is_expected.to contain_file('/etc/smartd.conf')
                .with_ensure('present')
                .without_content(%r{DEFAULT -m root -M daily})
                .with_content(%r{DEVICESCAN -m root -M daily})
            end
          end
        end
        # enable_default = default value

        context 'when true' do
          let(:params) { { enable_default: true } }

          it do
            is_expected.to contain_file('/etc/smartd.conf')
              .with_ensure('present')
              .with_content(%r{DEFAULT -m root -M daily})
          end
        end

        context 'when false' do
          let(:params) { { enable_default: false } }

          it do
            is_expected.to contain_file('/etc/smartd.conf')
              .with_ensure('present')
              .without_content(%r{DEFAULT -m root -M daily})
              .with_content(%r{DEVICESCAN -m root -M daily})
          end
        end
      end
      # enable_default =>

      describe 'default_options =>' do
        context 'when using default value' do
          let(:params) { {} }

          context 'with enable_default => true' do
            before(:each) do
              params[:enable_default] = true
            end

            it do
              is_expected.to contain_file('/etc/smartd.conf')
                .with_ensure('present')
                .with_content(%r{DEFAULT -m root -M daily})
            end
          end

          context 'with enable_default => false' do
            before(:each) do
              params[:enable_default] = false
            end

            it do
              is_expected.to contain_file('/etc/smartd.conf')
                .with_ensure('present')
                .without_content(%r{DEFAULT -m root -M daily})
                .with_content(%r{DEVICESCAN -m root -M daily})
            end
          end
        end
        # default value

        context 'when undef' do
          let(:params) { { default_options: nil } }

          context 'with enable_default => true' do
            before(:each) do
              params[:enable_default] = true
            end

            it do
              is_expected.to contain_file('/etc/smartd.conf')
                .with_ensure('present')
                .with_content(%r{DEFAULT -m root -M daily})
            end
          end

          context 'with enable_default => false' do
            before(:each) do
              params[:enable_default] = false
            end

            it do
              is_expected.to contain_file('/etc/smartd.conf')
                .with_ensure('present')
                .without_content(%r{DEFAULT -m root -M daily})
                .with_content(%r{DEVICESCAN -m root -M daily})
            end
          end
        end
        # default_options is undef

        context 'when -H' do
          let(:params) { { default_options: '-H' } }

          context 'with enable_default => true' do
            before(:each) do
              params[:enable_default] = true
            end

            it do
              is_expected.to contain_file('/etc/smartd.conf')
                .with_ensure('present')
                .with_content(%r{DEFAULT -m root -M daily -H})
            end
          end

          context 'with enable_default => false' do
            before(:each) do
              params[:enable_default] = false
            end

            it do
              is_expected.to contain_file('/etc/smartd.conf')
                .with_ensure('present')
                .without_content(%r{DEFAULT -m root -M daily -H})
                .with_content(%r{DEVICESCAN -m root -M daily -H})
            end
          end
        end
        # default_options is "-H"
      end
      # default_options
    end

    describe 'for osfamily Debian' do
      let(:facts) { { os: { family: 'Debian' }, smartmontools_version: '5.43' } }

      describe 'ensure => present' do
        let(:params) { { ensure: 'present' } }

        it { is_expected.to contain_augeas('shell_config_start_smartd').with_changes('set start_smartd "yes"') }
      end

      describe 'ensure => latest' do
        let(:params) { { ensure: 'latest' } }

        it { is_expected.to contain_augeas('shell_config_start_smartd').with_changes('set start_smartd "yes"') }
      end

      describe 'ensure => absent' do
        let(:params) { { ensure: 'absent' } }

        it { is_expected.to contain_augeas('shell_config_start_smartd').with_changes('remove start_smartd') }
      end

      describe 'ensure => purged' do
        let(:params) { { ensure: 'purged' } }

        it { is_expected.to contain_augeas('shell_config_start_smartd').with_changes('remove start_smartd') }
      end

      describe 'ensure => absent and service_ensure => running' do
        let(:params) { { ensure: 'absent', service_ensure: 'running' } }

        it { is_expected.to contain_augeas('shell_config_start_smartd').with_changes('remove start_smartd') }
      end

      describe 'ensure => purged and service_ensure => running' do
        let(:params) { { ensure: 'purged', service_ensure: 'running' } }

        it { is_expected.to contain_augeas('shell_config_start_smartd').with_changes('remove start_smartd') }
      end

      describe 'service_ensure => running' do
        let(:params) { { service_ensure: 'running' } }

        it { is_expected.to contain_augeas('shell_config_start_smartd').with_changes('set start_smartd "yes"') }
      end

      describe 'service_ensure => stopped' do
        let(:params) { { service_ensure: 'stopped' } }

        it { is_expected.to contain_augeas('shell_config_start_smartd').with_changes('remove start_smartd') }
      end
    end
  end

  describe 'megaraid support' do
    describe 'without params + megaraid sata facts' do
      let(:facts) do
        {
          os: {
            family: 'RedHat',
          },
          megaraid_adapters: '1',
          megaraid_virtual_drives: 'sdb,sda',
          megaraid_physical_drives_sata: '2,1',
          smartmontools_version: '5.43',
        }
      end

      it do
        is_expected.to contain_file('/etc/smartd.conf')
          .with_content(<<-ENDFILE.gsub(%r{^\s+}, ''))
            # Managed by Puppet -- do not edit!
            DEFAULT -m root -M daily
            /dev/sda -d sat+megaraid,1
            /dev/sda -d sat+megaraid,2
            DEVICESCAN
          ENDFILE
      end
    end

    describe 'without params + megaraid sas facts' do
      let(:facts) do
        {
          os: {
            family: 'RedHat',
          },
          megaraid_adapters: '1',
          megaraid_virtual_drives: 'sdb,sda',
          megaraid_physical_drives_sas: '2,1',
          smartmontools_version: '5.43',
        }
      end

      it do
        is_expected.to contain_file('/etc/smartd.conf')
          .with_content(<<-ENDFILE.gsub(%r{^\s+}, ''))
            # Managed by Puppet -- do not edit!
            DEFAULT -m root -M daily
            /dev/sda -d megaraid,1
            /dev/sda -d megaraid,2
            DEVICESCAN
          ENDFILE
      end
    end

    describe 'without params + megaraid sata+sas facts' do
      let(:facts) do
        {
          os: {
            family: 'RedHat',
          },
          megaraid_adapters: '1',
          megaraid_virtual_drives: 'sdb,sda',
          megaraid_physical_drives_sas: '1,2',
          megaraid_physical_drives_sata: '3,4',
          smartmontools_version: '5.43',
        }
      end

      it do
        is_expected.to contain_file('/etc/smartd.conf')
          .with_content(<<-ENDFILE.gsub(%r{^\s+}, ''))
            # Managed by Puppet -- do not edit!
            DEFAULT -m root -M daily
            /dev/sda -d sat+megaraid,3
            /dev/sda -d sat+megaraid,4
            /dev/sda -d megaraid,1
            /dev/sda -d megaraid,2
            DEVICESCAN
          ENDFILE
      end
    end

    describe 'with params + megaraid facts' do
      let(:facts) do
        {
          os: {
            family: 'RedHat',
          },
          megaraid_adapters: '1',
          megaraid_virtual_drives: 'sdb,sda',
          megaraid_physical_drives_sata: '2,1',
          smartmontools_version: '5.43',
        }
      end
      let(:params) do
        {
          devices: [{ 'device' => 'megaraid', 'options' => '-I 194' }],
        }
      end

      it do
        is_expected.to contain_class('smartd')
        is_expected.to contain_class('smartd::params')
        is_expected.to contain_package('smartmontools')
        is_expected.to contain_service('smartd')
        is_expected.to contain_file('/etc/smartd.conf')
          .with_content(<<-ENDFILE.gsub(%r{^\s+}, ''))
            # Managed by Puppet -- do not edit!
            DEFAULT -m root -M daily
            /dev/sda -d sat+megaraid,1 -I 194
            /dev/sda -d sat+megaraid,2 -I 194
            DEVICESCAN
          ENDFILE
      end
    end
  end
end
