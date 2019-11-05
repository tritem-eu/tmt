Tmt::Application.routes.draw do
  namespace 'api', module: 'tmt/api' do
    resources :projects, only: [] do
      resources :test_cases, path: "test-cases", only: [] do
        resources :test_case_versions, only: [:create], path: :versions, as: :versions do
          collection do
            post :check_md5, path: 'check-md5', as: 'check_md5'
          end
        end
      end
      resources :test
    end
  end

  # Documentation: https://github.com/plataformatec/devise/wiki/How-To:-Disable-user-from-destroying-his-account
  resource :admin, module: :tmt, controller: :admin

  scope :admin, module: :admin, as: :admin do
    resources :projects, only: [:new, :create, :index, :edit, :update]

    resources :users, except: [:show] do
      member do
        get :edit_role, path: 'edit-role', as: :edit_role
        put :update_role, path: 'update-role', as: :update_role
      end
    end
    resources :automation_adapters, only: [:new, :edit, :index, :update, :create], path: 'automation-adapters'
    resources :cfgs, only: [:index, :update]
    resources :campaigns, only: [:new, :edit,:create, :update, :index] do
      member do
        put :close
      end

      collection do
        get :info
      end
    end
    resources :machines, only: [:new, :edit, :create, :update, :index]

    resources :enumerations, except: [:show] do
      resources :enumeration_values, path: "values", only: [:new, :create, :edit, :update, :destroy]
    end
    resources :oslc_cfgs, only: [:index, :update], path: 'oslc-cfgs'
    resources :test_case_types, path: "test-case-types"
    resources :members, only: [:index, :create, :destroy]
    scope "test-case", as: "test_case", model_name: "test_case" do
      resources :custom_fields, path: "custom-fields" do
        member do
          get :clone, path: 'clone', as: :clone
        end
      end
    end

    scope "test-run", as: "test_run", model_name: "test_run" do
      resources :custom_fields, path: "custom-fields" do
        member do
          get :clone, path: 'clone', as: :clone
        end
      end
    end

  end

  devise_for :users, skip: [:reqistrations], controllers: {sessions: 'sessions'}

  devise_scope :user do
    resource :registration,
      only: [:new, :edit, :update, :create],
      controller: 'registrations',
      path: :users,
      path_name: {new: 'sign_up'},
      as: :user_registration
  end
  resources :users, module: :tmt, only: [:show]

  resources :projects, module: :tmt, only: [:show] do
    resources :test_cases, path: "test-cases" do
      member do
        put :toggle_steward, path: 'toggle-steward'
      end

      resources :test_case_versions, only: [:show, :create], path: :versions, as: :versions do
        member do
          get :progress
          get :download
          get :only_file, path: "only-file"
        end
      end
    end

    resources :test_cases_sets, path: "test-cases-sets"

    resources :sets do
      member do
        get :download
      end
    end

    resources :test_runs, path: "test-runs" do
      member do
        get 'clone'
        get 'terminate'
      end

      collection do
        get "calendar", to: 'test_runs#calendar'
        get "calendar/:year/months/:month", to: 'test_runs#calendar', as: 'calendar_month'
        get "calendar/:year/months/:month/days/:day", to: 'test_runs#calendar_day', as: 'calendar_month_day'
      end
    end

    resources :campaigns, only: [:show] do
      resources :test_runs, except: [:index], path: "test-runs" do
        member do
          put "set-status-planned", to: :set_status_planned, as: :set_status_planned
          put "set-status-executing", to: :set_status_executing, as: :set_status_executing
          put "set-status-new", to: :set_status_new, as: :set_status_new
          get "report"
        end
      end

      resources :executions, path: "executions", only: [:destroy, :show, :update] do
        collection do
          post "push_versions", path: 'push-versions', as: 'push_versions'
          get "show", path: "show"
          get "select_test_cases", path: "select-test-cases", as: 'select_test_cases'
          match "select_test_run", path: "select-test-run", as: 'select_test_run', via: [:get, :post]
          match "select_versions", path: "select-versions", as: 'select_versions', via: [:get, :post]
          post "select", path: "select"
          get 'upload_csv', path: 'upload-csv', as: 'upload_csv'
          post 'accept_csv', path: 'accept-csv', as: 'accept_csv'
        end

        member do
          get 'download-attached-file/:uuid', :action => 'download_attached_file', as: "download_attached_file"
          get :report, path: :report
          get :report_file, path: 'report-file', as: 'report_file'
        end
      end
    end
  end

  scope 'test-case/:source_id', source_type: "Tmt::TestCase", as: "test_case" do
    resources :external_relationships, path: "external-relationships", except: [:index], module: "tmt"
  end

  resource 'script', module: 'tmt', only: [:show] do
    member do
      post 'execute'
    end
  end

  scope 'oslc-extended-vocabulary', module: 'oslc/extended_vocabulary', path: 'oslc-extended-vocabulary', as: :oslc_extended_vocabulary do
    resource :qm
  end

  resource :rootservices, only: [:show], controller: 'oslc/rootservices'

  scope 'oslc', module: 'oslc', as: :oslc do
    resources :users, only: [:show]
    resource :rootservices, only: [:show], controller: 'rootservices'

    resources :errors, only: [:show]

    scope 'automation', module: "automation", as: :automation do
      resources :resource_shapes, path: "resource-shapes"
      resources :service_providers, only: [:index, :show], path: "service-providers" do
        resources :requests, only: [:show, :update] do
          collection do
            get 'query'
          end
        end

        resources :plans, only: [:show] do
          collection do
            get 'query'
          end
        end

        resources :results, only: [:show, :create] do
          collection do
            get 'query'
          end
        end

        resources :adapters, only: [:create, :show] do
          collection do
            get 'query'
          end
        end
      end
    end

    scope 'qm', module: "qm", as: :qm do
      resources :resource_shapes, path: "resource-shapes"
      resources :service_providers, only: [:index, :show], path: "service-providers" do
        resources :test_cases, path: "test-cases" do

          collection do
            get 'query'
            get 'selection_dialog', path: "selection-dialog"
            get 'new_creation_dialog', path: "new-creation-dialog"
            post 'creation_dialog', path: "creation-dialog"
          end
        end

        resources :test_plans, path: "test-plans", only: [:show, :index] do
          collection do
            get 'query'
            get 'selection_dialog', path: "selection-dialog"
            get 'new_creation_dialog', path: "new-creation-dialog"
            post 'creation_dialog', path: "creation-dialog"
            get 'unexecuted'
          end

          member do
            put 'set_status_executing', path: "set-status-executing"
          end

        end

        resources :test_scripts, path: "test-scripts", only: [:show] do
          member do
            get :download
          end

          collection do
            get 'query'
            get 'selection_dialog', path: "selection-dialog"
          end
        end

        resources :test_execution_records, path: "test-execution-records", only: [:show] do
          collection do
            get "query"
            get 'selection_dialog', path: "selection-dialog"
          end
        end

        resources :test_results, path: "test-results", only: [:show, :update] do
          collection do
            get 'query'
            get 'selection_dialog', path: "selection-dialog"
          end
        end

      end
    end
  end

  root :to => "tmt/home#index"
end
