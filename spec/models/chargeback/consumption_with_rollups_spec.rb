describe Chargeback::ConsumptionWithRollups do
  let(:vm)          { FactoryGirl.build(:vm_microsoft) }
  let(:consumption) { described_class.new([metric_rollup], starting_date, starting_date + 1.day) }

  describe '#sub_metric_rollups' do
    let(:starting_date)        { Time.parse('2012-09-01 23:59:59Z').utc }
    let(:sub_metric)           { 'ssd' }
    let(:ssd_volume)           { FactoryGirl.create(:cloud_volume_openstack, :volume_type => sub_metric) }
    let!(:state)         { FactoryGirl.create(:vim_performance_state, :resource => vm, :state_data => nil, :timestamp => starting_date, :capture_interval => 3_600) }
    let!(:metric_rollup) { FactoryGirl.create(:metric_rollup_vm_hr, :timestamp => starting_date + 1.hour, :resource => vm) }

    before do
      Timecop.travel(starting_date)
    end

    it "doesn't fail when there are no state data about disks" do
      expect(consumption.send(:values, 'derived_vm_allocated_disk_storage', sub_metric)).to match_array([0])
    end

    context 'vim performance state contains any state data for storage' do
      let(:volume_size) { 1_024 }

      before do
        state.capture
        state.allocated_disk_types = {sub_metric => volume_size}
        state.save
      end

      it 'returns values' do
        expect(consumption.send(:values, 'derived_vm_allocated_disk_storage', sub_metric)).to match_array([volume_size])
      end
    end

    after do
      Timecop.return
    end
  end
end
