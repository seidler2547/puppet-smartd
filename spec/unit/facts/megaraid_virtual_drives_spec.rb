require 'spec_helper'

describe 'megaraid_virtual_drives', type: :fact do
  before(:each) { Facter.clear }

  describe 'when on linux' do
    context 'with megacli not in path' do
      it do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return(nil)

        expect(Facter.fact(:megaraid_virtual_drives).value).to be_nil
      end
    end

    context 'with megacli broken' do
      it do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megaraid_adapters)).to receive(:value).and_return(nil)

        expect(Facter.fact(:megaraid_virtual_drives).value).to be_nil
      end
    end

    context 'with no adapters' do
      it do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megaraid_adapters)).to receive(:value).and_return('0')

        expect(Facter.fact(:megaraid_virtual_drives).value).to be_nil
      end
    end

    context 'with 1 adapter' do
      before(:each) do
        facts = {
          blockdevice_sda_model: 'MR9286CV-8e',
          blockdevice_sda_size: '32001801322496',
          blockdevice_sda_vendor: 'LSI',
          blockdevice_sdb_model: 'MR9286CV-8e',
          blockdevice_sdb_size: '32001801322496',
          blockdevice_sdb_vendor: 'LSI',
          blockdevice_sdc_model: 'MR9286CV-8e',
          blockdevice_sdc_size: '32001801322496',
          blockdevice_sdc_vendor: 'LSI',
          blockdevice_sdd_model: 'MR9286CV-8e',
          blockdevice_sdd_size: '32001801322496',
          blockdevice_sdd_vendor: 'LSI',
          blockdevice_sde_model: 'MR9286CV-8e',
          blockdevice_sde_size: '199481098240',
          blockdevice_sde_vendor: 'LSI',
          blockdevice_sdf_model: 'MR9286CV-8e',
          blockdevice_sdf_size: '32001801322496',
          blockdevice_sdf_vendor: 'LSI',
          blockdevice_sdg_model: 'MR9286CV-8e',
          blockdevice_sdg_size: '32001801322496',
          blockdevice_sdg_vendor: 'LSI',
          blockdevice_sdh_model: 'MR9286CV-8e',
          blockdevice_sdh_size: '199481098240',
          blockdevice_sdh_vendor: 'LSI',
          blockdevice_sdi_model: 'INTEL SSDSC2CW12',
          blockdevice_sdi_size: '120034123776',
          blockdevice_sdi_vendor: 'ATA',
          blockdevice_sdj_model: 'INTEL SSDSC2CW12',
          blockdevice_sdj_size: '120034123776',
          blockdevice_sdj_vendor: 'ATA',
          blockdevice_sdk_model: 'PRAID EP400i',
          blockdevice_sdk_size: '299439751168',
          blockdevice_sdk_vendor: 'FTS',
          blockdevices: 'sda,sdb,sdc,sdd,sde,sdf,sdg,sdh,sdi,sdj,sdk',
        }

        # stolen from rspec-puppet
        facts.each { |k, v| Facter.add(k) { setcode { v } } }
      end

      it do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(Facter.fact(:megacli)).to receive(:value).and_return('/usr/bin/MegaCli')
        allow(Facter.fact(:megaraid_adapters)).to receive(:value).and_return('1')

        expect(Facter.fact(:megaraid_virtual_drives).value).to eq('sda,sdb,sdc,sdd,sde,sdf,sdg,sdh,sdk')
      end
    end
  end
  # on linux

  context 'when not on linux' do
    it do
      allow(Facter.fact(:kernel)).to receive(:value).and_return('Solaris')

      expect(Facter.fact(:megaraid_virtual_drives).value).to be_nil
    end
  end
  # not on linux
end
