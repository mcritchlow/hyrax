describe Hyrax::Workflow::WorkflowByAdminSetStrategy, :no_clean do
  context "when using default workflow strategy" do
    let(:workflow_strategy) { described_class.new(nil, {}) }

    describe '#workflow_id' do
      subject { workflow_strategy.workflow_id }
      it { is_expected.to eq 1 }
    end
  end

  context "when using a non-default workflow strategy" do
    let!(:admin_set) { AdminSet.create(title: ["test"]) }
    let!(:permission_template) { Hyrax::PermissionTemplate.create(workflow_id: workflow_id, admin_set_id: admin_set.id) }
    let(:workflow_id) { 1 }
    let(:workflow_strategy) { described_class.new(nil, admin_set_id: admin_set.id) }

    describe '#workflow_id' do
      subject { workflow_strategy.workflow_id }
      it { is_expected.to eq workflow_id }
    end
  end
end
