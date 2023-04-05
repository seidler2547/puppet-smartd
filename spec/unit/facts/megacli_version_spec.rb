require 'spec_helper'

describe 'megacli_version', type: :fact do
  before(:each) { Facter.clear }

  context 'when megacli fact not set' do
    it 'fact returns nil' do
      allow(Facter.fact(:megacli)).to receive(:value).and_return(nil)
      expect(Facter.fact(:megacli_version).value).to be_nil
    end
  end

  context 'when megacli fact is broken' do
    it 'fact returns nil' do
      allow(Facter.fact(:megacli)).to receive(:value).and_return('foobar')
      expect(Facter.fact(:megacli_version).value).to be_nil
    end
  end

  context 'when megacli fact is working' do
    it 'returns the version string using modern binary' do
      allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
      allow(Facter::Util::Resolution).to receive(:exec)
        .with('/usr/bin/MegaCli -Version -Cli -aALL -NoLog')
        .and_return(File.read(fixtures('megacli', 'version-cli-aall-8.07.07')))
      expect(Facter.fact(:megacli_version).value).to eq('8.07.07')
    end

    it 'returns the version string using legacy binary' do
      allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
      allow(Facter::Util::Resolution).to receive(:exec)
        .with('/usr/bin/MegaCli -Version -Cli -aALL -NoLog')
        .and_return(File.read(fixtures('megacli', 'invalid-input-8.00.11')))
      allow(Facter::Util::Resolution).to receive(:exec)
        .with('/usr/bin/MegaCli -v -aALL -NoLog')
        .and_return(File.read(fixtures('megacli', 'version-aall-8.00.11')))
      expect(Facter.fact(:megacli_version).value).to eq('8.00.11')
    end
  end
end
