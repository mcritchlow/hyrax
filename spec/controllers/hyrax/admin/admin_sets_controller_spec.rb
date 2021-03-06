require 'spec_helper'

describe Hyrax::Admin::AdminSetsController do
  routes { Hyrax::Engine.routes }
  let(:user) { create(:user) }

  context "a non admin" do
    describe "#index" do
      it 'is unauthorized' do
        get :index
        expect(response).to be_redirect
      end
    end

    describe "#new" do
      let!(:admin_set) { create(:admin_set) }

      it 'is unauthorized' do
        get :new
        expect(response).to be_redirect
      end
    end

    describe "#show" do
      context "a public admin set" do
        # Even though the user can view this admin set, the should not be able to view
        # it on the admin page.
        let(:admin_set) { create(:admin_set, :public) }
        it 'is unauthorized' do
          get :show, params: { id: admin_set }
          expect(response).to be_redirect
        end
      end
    end
  end

  context "as an admin" do
    before do
      sign_in user
      allow(controller).to receive(:authorize!).and_return(true)
    end

    describe "#index" do
      it 'allows an authorized user to view the page' do
        get :index
        expect(response).to be_success
        expect(assigns[:admin_sets]).to be_kind_of Array
      end
    end

    describe "#new" do
      it 'allows an authorized user to view the page' do
        get :new
        expect(response).to be_success
      end
    end

    describe "#create" do
      before do
        controller.admin_set_create_service = service
      end

      context "when it's successful" do
        let(:service) do
          lambda do |admin_set, _|
            admin_set.id = 123
            true
          end
        end
        it 'creates file sets' do
          post :create, params: { admin_set: { title: 'Test title',
                                               description: 'test description',
                                               workflow_name: 'default' } }
          admin_set = assigns(:admin_set)
          expect(response).to redirect_to(edit_admin_admin_set_path(admin_set))
        end
      end

      context "when it fails" do
        let(:service) { ->(_, _) { false } }
        it 'shows the new form' do
          post :create, params: { admin_set: { title: 'Test title',
                                               description: 'test description' } }
          expect(response).to render_template 'new'
        end
      end
    end

    describe "#show" do
      context "when it's successful" do
        let(:admin_set) { create(:admin_set, edit_users: [user]) }
        before do
          create(:work, :public, admin_set: admin_set)
        end

        it 'defines a presenter' do
          get :show, params: { id: admin_set }
          expect(response).to be_success
          expect(assigns[:presenter]).to be_kind_of Hyrax::AdminSetPresenter
          expect(assigns[:presenter].id).to eq admin_set.id
        end
      end
    end

    describe "#edit" do
      let(:admin_set) { create(:admin_set, edit_users: [user]) }
      it 'defines a form' do
        get :edit, params: { id: admin_set }
        expect(response).to be_success
        expect(assigns[:form]).to be_kind_of Hyrax::Forms::AdminSetForm
      end
    end

    describe "#update" do
      let(:admin_set) { create(:admin_set, edit_users: [user]) }
      let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by(admin_set_id: admin_set.id) }
      it 'updates a record' do
        # Prevent a save which causes Fedora to complain it doesn't know the referenced node.
        expect_any_instance_of(AdminSet).to receive(:save).and_return(true)
        patch :update, params: { id: admin_set,
                                 admin_set: { title: "Improved title", thumbnail_id: "mw22v559x", workflow_name: "one_step_mediated_deposit" } }
        expect(response).to be_redirect
        expect(assigns[:admin_set].title).to eq ['Improved title']
        expect(assigns[:admin_set].thumbnail_id).to eq 'mw22v559x'
        expect(permission_template.workflow_name).to eq 'one_step_mediated_deposit'
      end
    end
  end
end
