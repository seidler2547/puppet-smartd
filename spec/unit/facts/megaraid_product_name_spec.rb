require 'spec_helper'

describe 'megaraid_product_name', type: :fact do
  before(:each) { Facter.clear }

  context 'when megacli fact not set' do
    it 'returns nil' do
      allow(Facter.fact(:megacli)).to receive(:value).and_return(nil)
      expect(Facter.fact(:megaraid_product_name).value).to be_nil
    end
  end

  context 'when megacli fact is broken' do
    it 'returns nil' do
      allow(Facter.fact(:megacli)).to receive(:value).and_return('foobar')
      expect(Facter.fact(:megaraid_product_name).value).to be_nil
    end
  end

  context 'when megacli fact is working' do
    context 'with modern binary' do
      it 'returns the product name string using the modern binary' do
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megacli_legacy)).to receive(:value).and_return(false)
        allow(Facter::Util::Resolution).to receive(:exec)
          .with('/usr/bin/MegaCli -Version -Ctrl -aALL -NoLog')
          .and_return(File.read(fixtures('megacli', 'version-ctrl-aall-8.07.07')))
        expect(Facter.fact(:megaraid_product_name).value).to eq('LSI MegaRAID SAS 9286CV-8e')
      end
    end

    context 'with legacy binary' do
      it 'returns the product name string using legacy binary' do
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megacli_legacy)).to receive(:value).and_return(true)
        allow(Facter::Util::Resolution).to receive(:exec)
          .with('/usr/bin/MegaCli -AdpAllInfo -aALL -NoLog')
          .and_return(File.read(fixtures('megacli', 'adpallinfo-aall-8.00.11')))
        expect(Facter.fact(:megaraid_product_name).value).to eq('PERC H310 Mini')
      end
    end
  end
end
