require 'spec_helper'

describe 'megaraid_adapters', type: :fact do
  before(:each) { Facter.clear }

  context 'when on linux' do
    context 'with megacli not in path' do
      it do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return(nil)

        expect(Facter.fact(:megaraid_adapters).value).to be_nil
      end
    end

    context 'with megacli being broken' do
      it do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter::Util::Resolution).to receive(:exec)
          .with('/usr/bin/MegaCli -adpCount -NoLog 2>&1')
          .and_return(nil)

        expect(Facter.fact(:megaraid_adapters).value).to eq('0')
      end
    end

    context 'with megacli working' do
      it 'finds 0 adapters' do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter::Util::Resolution).to receive(:which).with('MegaCli').and_return('/usr/bin/MegaCli')
        allow(Facter::Util::Resolution).to receive(:exec)
          .with('/usr/bin/MegaCli -adpCount -NoLog 2>&1')
          .and_return(File.read(fixtures('megacli', 'adpcount-count_0')))

        expect(Facter.fact(:megaraid_adapters).value).to eq('0')
      end

      it 'finds 1 adapter' do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter::Util::Resolution).to receive(:which).with('MegaCli').and_return('/usr/bin/MegaCli')
        allow(Facter::Util::Resolution).to receive(:exec)
          .with('/usr/bin/MegaCli -adpCount -NoLog 2>&1')
          .and_return(File.read(fixtures('megacli', 'adpcount-count_1')))

        expect(Facter.fact(:megaraid_adapters).value).to eq('1')
      end
    end
  end
  # on linux

  context 'when not on linux' do
    it do
      allow(Facter.fact(:kernel)).to receive(:value).and_return('Solaris')

      expect(Facter.fact(:megaraid_adapters).value).to be_nil
    end
  end
  # not on linux
end
