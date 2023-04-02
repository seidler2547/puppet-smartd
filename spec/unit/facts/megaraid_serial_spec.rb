require 'spec_helper'

describe 'megaraid_serial', type: :fact do
  before(:each) { Facter.clear }

  context 'when megacli fact not set' do
    it 'returns nil' do
      Facter.fact(:megacli).stubs(:value).returns(nil)
      expect(Facter.fact(:megaraid_serial).value).to be_nil
    end
  end

  context 'when megacli fact is broken' do
    it 'returns nil' do
      Facter.fact(:megacli).stubs(:value).returns('foobar')
      expect(Facter.fact(:megaraid_serial).value).to be_nil
    end
  end

  context 'when megacli fact is working' do
    context 'with modern binary' do
      it 'returns the serial number using modern binary' do
        Facter.fact(:megacli).stubs(:value).returns('/usr/bin/MegaCli')
        Facter.fact(:megacli_legacy).stubs(:value).returns(false)
        Facter::Util::Resolution
          .stubs(:exec)
          .with('/usr/bin/MegaCli -Version -Ctrl -aALL -NoLog')
          .returns(File.read(fixtures('megacli', 'version-ctrl-aall-8.07.07')))
        expect(Facter.fact(:megaraid_serial).value).to eq('SV22925366')
      end

      context 'without serial number in megacli output' do
        it 'returns nil' do
          Facter.fact(:megacli).stubs(:value).returns('/usr/bin/MegaCli')
          Facter.fact(:megacli_legacy).stubs(:value).returns(false)
          Facter::Util::Resolution
            .stubs(:exec)
            .with('/usr/bin/MegaCli -Version -Ctrl -aALL -NoLog')
            .returns(File.read(fixtures('megacli', 'version-ctrl-aall-sm_no_serial')))
          expect(Facter.fact(:megaraid_serial).value).to be_nil
        end
      end
    end

    context 'with legacy binary' do
      it 'returns the serial number using legacy binary' do
        Facter.fact(:megacli).stubs(:value).returns('/usr/bin/MegaCli')
        Facter.fact(:megacli_legacy).stubs(:value).returns(true)
        Facter::Util::Resolution
          .stubs(:exec)
          .with('/usr/bin/MegaCli -AdpAllInfo -aALL -NoLog')
          .returns(File.read(fixtures('megacli', 'adpallinfo-aall-8.00.11')))
        expect(Facter.fact(:megaraid_serial).value).to eq('34A03AB')
      end

      context 'without serial number in megacli output' do
        it 'returns nil' do
          Facter.fact(:megacli).stubs(:value).returns('/usr/bin/MegaCli')
          Facter.fact(:megacli_legacy).stubs(:value).returns(true)
          Facter::Util::Resolution
            .stubs(:exec)
            .with('/usr/bin/MegaCli -AdpAllInfo -aALL -NoLog')
            .returns(File.read(fixtures('megacli', 'adpallinfo-aall-8.00.11-dell_no_serial')))
          expect(Facter.fact(:megaraid_serial).value).to be_nil
        end
      end
    end
  end
end
