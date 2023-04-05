require 'spec_helper'

describe 'smartd', type: :fact do
  before(:each) { Facter.clear }

  context 'when smartd not in path' do
    it do
      allow(Facter::Util::Resolution).to receive(:which).with('smartd').and_return(nil)
      expect(Facter.fact(:smartd).value).to be_nil
    end
  end

  context 'when smartd in path' do
    it do
      allow(Facter::Util::Resolution).to receive(:which).with('smartd').and_return('/usr/sbin/smartd')
      expect(Facter.fact(:smartd).value).to eq('/usr/sbin/smartd')
    end
  end
end
