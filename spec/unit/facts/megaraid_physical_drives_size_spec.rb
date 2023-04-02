require 'spec_helper'

describe 'megaraid_physical_drives_size', type: :fact do
  before(:each) { Facter.clear }

  describe 'when on linux' do
    context 'with megacli not in path' do
      it do
        Facter.fact(:kernel).stubs(:value).returns('Linux')
        Facter.fact(:megacli).stubs(:value).returns(nil)

        expect(Facter.fact(:megaraid_physical_drives_size).value).to be_nil
      end
    end

    context 'with megacli broken' do
      it do
        Facter.fact(:kernel).stubs(:value).returns('Linux')
        Facter.fact(:megacli).stubs(:value).returns('/usr/bin/MegaCli')
        Facter.fact(:megaraid_adapters).stubs(:value).returns(nil)

        expect(Facter.fact(:megaraid_physical_drives_size).value).to be_nil
      end

      it do
        Facter.fact(:kernel).stubs(:value).returns('Linux')
        Facter.fact(:megacli).stubs(:value).returns('/usr/bin/MegaCli')
        Facter.fact(:megaraid_adapters).stubs(:value).returns('1')
        Facter::Util::Resolution
          .stubs(:exec)
          .with('/usr/bin/MegaCli -PDList -aALL -NoLog')
          .returns(nil)

        expect(Facter.fact(:megaraid_physical_drives_size).value).to be_nil
      end
    end

    context 'with no adapters' do
      it do
        Facter.fact(:kernel).stubs(:value).returns('Linux')
        Facter.fact(:megacli).stubs(:value).returns('/usr/bin/MegaCli')
        Facter.fact(:megaraid_adapters).stubs(:value).returns('0')

        expect(Facter.fact(:megaraid_physical_drives_size).value).to be_nil
      end
    end

    context 'with 1 adapter' do
      let(:sizes) do
        '3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,'     \
          '3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,'   \
          '3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,'   \
          '3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,'   \
          '3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,'   \
          '3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,'   \
          '3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,186.310 GB,' \
          '186.310 GB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,' \
          '3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,'   \
          '3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,'   \
          '3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB,3.638 TB'
      end

      it do
        Facter.fact(:kernel).stubs(:value).returns('Linux')
        Facter.fact(:megacli).stubs(:value).returns('/usr/bin/MegaCli')
        Facter.fact(:megaraid_adapters).stubs(:value).returns('1')
        Facter::Util::Resolution
          .stubs(:exec)
          .with('/usr/bin/MegaCli -PDList -aALL -NoLog')
          .returns(File.read(fixtures('megacli', 'pdlistaall')))
        expect(Facter.fact(:megaraid_physical_drives_size).value).to eq(sizes)
      end
    end
  end
  # on linux

  context 'when not on linux' do
    it do
      Facter.fact(:kernel).stubs(:value).returns('Solaris')

      expect(Facter.fact(:megaraid_physical_drives_size).value).to be_nil
    end
  end
  # not on linux
end
