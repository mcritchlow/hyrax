module Hyrax
  module Workflow
    class WorkflowByModelNameStrategy
      def initialize(work, _attributes)
        @work = work
      end

      # @return [String] The id of the workflow to use
      def workflow_id
        1
      end
    end
  end
end
