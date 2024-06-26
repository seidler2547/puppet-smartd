require 'spec_helper'

describe 'megaraid_serial', type: :fact do
  before(:each) { Facter.clear }

  context 'when megacli fact not set' do
    it 'returns nil' do
      allow(Facter.fact(:megacli)).to receive(:value).and_return(nil)
      expect(Facter.fact(:megaraid_serial).value).to be_nil
    end
  end

  context 'when megacli fact is broken' do
    it 'returns nil' do
      allow(Facter.fact(:megacli)).to receive(:value).and_return('foobar')
      expect(Facter.fact(:megaraid_serial).value).to be_nil
    end
  end

  context 'when megacli fact is working' do
    context 'with modern binary' do
      it 'returns the serial number using modern binary' do
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megacli_legacy)).to receive(:value).and_return(false)
        allow(Facter::Util::Resolution).to receive(:exec)
          .with('/usr/bin/MegaCli -Version -Ctrl -aALL -NoLog')
          .and_return(File.read(fixtures('megacli', 'version-ctrl-aall-8.07.07')))
        expect(Facter.fact(:megaraid_serial).value).to eq('SV22925366')
      end

      context 'without serial number in megacli output' do
        it 'returns nil' do
          allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
          allow(Facter.fact(:megacli_legacy)).to receive(:value).and_return(false)
          allow(Facter::Util::Resolution).to receive(:exec)
            .with('/usr/bin/MegaCli -Version -Ctrl -aALL -NoLog')
            .and_return(File.read(fixtures('megacli', 'version-ctrl-aall-sm_no_serial')))
          expect(Facter.fact(:megaraid_serial).value).to be_nil
        end
      end
    end

    context 'with legacy binary' do
      it 'returns the serial number using legacy binary' do
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megacli_legacy)).to receive(:value).and_return(true)
        allow(Facter::Util::Resolution).to receive(:exec)
          .with('/usr/bin/MegaCli -AdpAllInfo -aALL -NoLog')
          .and_return(File.read(fixtures('megacli', 'adpallinfo-aall-8.00.11')))
        expect(Facter.fact(:megaraid_serial).value).to eq('34A03AB')
      end

      context 'without serial number in megacli output' do
        it 'returns nil' do
          allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
          allow(Facter.fact(:megacli_legacy)).to receive(:value).and_return(true)
          allow(Facter::Util::Resolution).to receive(:exec)
            .with('/usr/bin/MegaCli -AdpAllInfo -aALL -NoLog')
            .and_return(File.read(fixtures('megacli', 'adpallinfo-aall-8.00.11-dell_no_serial')))
          expect(Facter.fact(:megaraid_serial).value).to be_nil
        end
      end
    end
  end
end
