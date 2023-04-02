require 'spec_helper'

describe 'megacli', type: :fact do
  before(:each) { Facter.clear }

  context 'when on linux' do
    context 'with megacli not in path' do
      it do
        Facter.fact(:kernel).stubs(:value).returns('Linux')
        Facter::Util::Resolution.stubs(:which).with('MegaCli').returns(nil)
        Facter::Util::Resolution.stubs(:which).with('megacli').returns(nil)
        expect(Facter.fact(:megacli).value).to be_nil
      end
    end

    context 'with megacli in path mixed case' do
      it do
        Facter.fact(:kernel).stubs(:value).returns('Linux')
        Facter::Util::Resolution.stubs(:which).with('MegaCli').returns('/usr/bin/MegaCli')
        expect(Facter.fact(:megacli).value).to eq('/usr/bin/MegaCli')
      end
    end

    context 'with megacli in path lower case' do
      it do
        Facter.fact(:kernel).stubs(:value).returns('Linux')
        Facter::Util::Resolution.stubs(:which).with('MegaCli').returns(nil)
        Facter::Util::Resolution.stubs(:which).with('megacli').returns('/usr/bin/megacli')
        expect(Facter.fact(:megacli).value).to eq('/usr/bin/megacli')
      end
    end
  end
end
