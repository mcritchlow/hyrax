module Hyrax
  module Workflow
    class DefaultWorkflowStrategy
      def initialize(_work, _attributes); end

      # @return [String] The id of the workflow to use
      def workflow_id
        1
      end
    end
  end
end
