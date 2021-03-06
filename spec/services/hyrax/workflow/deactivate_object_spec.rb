require 'spec_helper'

RSpec.describe Hyrax::Workflow::DeactivateObject do
  let(:work) { create(:generic_work) }
  let(:user) { create(:user) }

  describe ".call" do
    it "makes it inactive" do
      if RDF::VERSION.to_s < '2.0'
        expect { described_class.call(target: work, comment: "A pleasant read", user: user) }
          .to change { work.state }
          .from(nil)
          .to(instance_of(ActiveTriples::Resource))
      else
        expect { described_class.call(target: work, comment: "A pleasant read", user: user) }
          .to change { work.state }
          .from(nil)
          .to(::RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#inactive'))
      end
    end
  end
end
