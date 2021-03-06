module Hyrax
  module BatchEditsControllerBehavior
    extend ActiveSupport::Concern
    include Hyrax::Breadcrumbs

    included do
      before_action :build_breadcrumbs, only: :edit

      # provides the help_text view method
      helper PermissionsHelper
    end

    def edit
      super
      work = form_class.model_class.new
      work.depositor = current_user.user_key
      @form = form_class.new(work, current_user, batch)
    end

    def after_update
      respond_to do |format|
        format.json { head :no_content }
        format.html { redirect_to_return_controller }
      end
    end

    def after_destroy_collection
      redirect_to_return_controller unless request.xhr?
    end

    def update_document(obj)
      obj.attributes = work_params
      obj.date_modified = Time.current.ctime
      obj.visibility = params[:visibility]
    end

    def update
      case params["update_type"]
      when "update"
        super
      when "delete_all"
        destroy_batch
      end
    end

    protected

      def add_breadcrumb_for_controller
        add_breadcrumb I18n.t('hyrax.dashboard.my.works'), hyrax.dashboard_works_path
      end

      def _prefixes
        # This allows us to use the templates in hyrax/base, while prefering
        # our local paths. Thus we are unable to just override `self.local_prefixes`
        @_prefixes ||= super + ['hyrax/base']
      end

      def destroy_batch
        batch.each { |id| ActiveFedora::Base.find(id).destroy }
        after_update
      end

      def form_class
        Forms::BatchEditForm
      end

      def terms
        form_class.terms
      end

      def work_params
        work_params = params[form_class.model_name.param_key] || ActionController::Parameters.new
        form_class.model_attributes(work_params)
      end

      def redirect_to_return_controller
        if params[:return_controller]
          redirect_to hyrax.url_for(controller: params[:return_controller], only_path: true)
        else
          redirect_to hyrax.dashboard_index_path
        end
      end
  end
end
