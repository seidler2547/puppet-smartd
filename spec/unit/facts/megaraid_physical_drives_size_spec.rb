require 'spec_helper'

describe 'megaraid_physical_drives_size', type: :fact do
  before(:each) { Facter.clear }

  describe 'when on linux' do
    context 'with megacli not in path' do
      it do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return(nil)

        expect(Facter.fact(:megaraid_physical_drives_size).value).to be_nil
      end
    end

    context 'with megacli broken' do
      it do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megaraid_adapters)).to receive(:value).and_return(nil)

        expect(Facter.fact(:megaraid_physical_drives_size).value).to be_nil
      end

      it do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megaraid_adapters)).to receive(:value).and_return('1')
        allow(Facter::Util::Resolution).to receive(:exec)
          .with('/usr/bin/MegaCli -PDList -aALL -NoLog')
          .and_return(nil)

        expect(Facter.fact(:megaraid_physical_drives_size).value).to be_nil
      end
    end

    context 'with no adapters' do
      it do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megaraid_adapters)).to receive(:value).and_return('0')

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
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megaraid_adapters)).to receive(:value).and_return('1')
        allow(Facter::Util::Resolution).to receive(:exec)
          .with('/usr/bin/MegaCli -PDList -aALL -NoLog')
          .and_return(File.read(fixtures('megacli', 'pdlistaall')))
        expect(Facter.fact(:megaraid_physical_drives_size).value).to eq(sizes)
      end
    end
  end
  # on linux

  context 'when not on linux' do
    it do
      allow(Facter.fact(:kernel)).to receive(:value).and_return('Solaris')

      expect(Facter.fact(:megaraid_physical_drives_size).value).to be_nil
    end
  end
  # not on linux
end
