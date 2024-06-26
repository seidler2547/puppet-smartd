require 'spec_helper'

describe 'smartd::params', type: :class do
  shared_examples 'osfamily' do |family|
    let(:facts) { { os: { family: family } } }

    it { is_expected.to contain_class('smartd::params') }
  end

  describe 'for osfamily RedHat' do
    let(:facts) do
      super().merge(
        {
          os: {
            name: 'RedHat',
            release: {
              major: '6',
            },
          },
        },
      )
    end

    it_behaves_like 'osfamily', 'RedHat'
  end

  describe 'for osfamily Debian' do
    it_behaves_like 'osfamily', 'Debian'
  end

  describe 'for osfamily FreeBSD' do
    it_behaves_like 'osfamily', 'FreeBSD'
  end

  describe 'unsupported osfamily' do
    let :facts do
      {
        os: {
          family: 'Solaris',
          name: 'Solaris',
        },
      }
    end

    it 'fails on unsupported OS' do
      is_expected.to compile.and_raise_error(%r{not supported on Solaris})
    end
  end
end
