require 'spec_helper'

describe 'megaraid_fw_package_build', type: :fact do
  before(:each) { Facter.clear }

  context 'when megacli fact not set' do
    it 'returns nil' do
      Facter.fact(:megacli).stubs(:value).returns(nil)
      expect(Facter.fact(:megaraid_fw_package_build).value).to be_nil
    end
  end

  context 'when megacli fact is broken' do
    it 'returns nil' do
      Facter.fact(:megacli).stubs(:value).returns('foobar')
      expect(Facter.fact(:megaraid_fw_package_build).value).to be_nil
    end
  end

  context 'when megacli fact is working' do
    context 'with modern binary' do
      it 'returns the version string using modern binary' do
        Facter.fact(:megacli).stubs(:value).returns('/usr/bin/MegaCli')
        Facter.fact(:megacli_legacy).stubs(:value).returns(false)
        Facter::Util::Resolution
          .stubs(:exec)
          .with('/usr/bin/MegaCli -Version -Ctrl -aALL -NoLog')
          .returns(File.read(fixtures('megacli', 'version-ctrl-aall-8.07.07')))
        expect(Facter.fact(:megaraid_fw_package_build).value).to eq('23.22.0-0012')
      end
    end

    context 'with legacy binary' do
      it 'returns the version string using legacy binary' do
        Facter.fact(:megacli).stubs(:value).returns('/usr/bin/MegaCli')
        Facter.fact(:megacli_legacy).stubs(:value).returns(true)
        Facter::Util::Resolution
          .stubs(:exec)
          .with('/usr/bin/MegaCli -AdpAllInfo -aALL -NoLog')
          .returns(File.read(fixtures('megacli', 'adpallinfo-aall-8.00.11')))
        expect(Facter.fact(:megaraid_fw_package_build).value).to eq('20.12.0-0004')
      end
    end
  end
end
