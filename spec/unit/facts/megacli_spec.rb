require 'spec_helper'

describe 'megacli', type: :fact do
  before(:each) { Facter.clear }

  context 'when on linux' do
    context 'with megacli not in path' do
      let(:facts) do
        {
          kernel: 'Linux',
        }
      end

      it do
        allow(Facter::Util::Resolution).to receive(:which).with('MegaCli').and_return(nil)
        allow(Facter::Util::Resolution).to receive(:which).with('megacli').and_return(nil)
        expect(Facter.fact(:megacli).value).to be_nil
      end
    end

    context 'with megacli in path mixed case' do
      it do
        allow(Facter::Util::Resolution).to receive(:which).with('MegaCli').and_return('/usr/bin/MegaCli')
        expect(Facter.fact(:megacli).value).to eq('/usr/bin/MegaCli')
      end
    end

    context 'with megacli in path lower case' do
      it do
        allow(Facter::Util::Resolution).to receive(:which).with('MegaCli').and_return(nil)
        allow(Facter::Util::Resolution).to receive(:which).with('megacli').and_return('/usr/bin/megacli')
        expect(Facter.fact(:megacli).value).to eq('/usr/bin/megacli')
      end
    end
  end
end
