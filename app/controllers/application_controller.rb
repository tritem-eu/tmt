class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exceptien.
  #   For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_instance_variables
  before_action :set_request_url, :set_request_path

  before_filter :set_host
  before_filter :sign_out_for_deleted_user

  def set_host
    #ActionMailer::Base.default_url_options[:host] = request.host_with_port
    #Rails.application.routes.default_url_options[:host] = request.host_with_port
  end

  before_action do
    ::User.updater_id = current_user.id if current_user
  end

  before_filter do
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "fri, 01 jan 1990 00:00:00 gmt"
  end

  before_action do
    Time.zone = set_instance_variables.time_zone if set_instance_variables
  end

  after_action do
    headers['X-Frame-Options'] = 'ALLOWALL'
  end

  def set_instance_variables
    @cfg ||= Tmt::Cfg.first
  end

  def self.before_render(method, options={}, &block)
    @@before_render ||= {}
    @@before_render[name] ||= []
    @@before_render[name] << [method, options]
  end

  def render(*args, &block)
    @@before_render ||= {}
    @@before_render[self.class.to_s] ||= []

    @@before_render[self.class.to_s].each do |method, options={}|
      if options[:only] and options[:only].include?(action_name.to_sym)
        send(method)
      end
    end
    super
  end

  def sign_out_for_deleted_user
    if current_user.is_a?(User) and current_user.deleted?
      sign_out current_user
      flash.delete(:notice)
      flash[:alert] = "This account has been deleted by an admin."
      root_path
    end
  end

  def request_format
    request.format.symbol
  rescue
    nil
  end

  # Handle authorization exceptions
  rescue_from CanCan::AccessDenied do |exception|
    case request.format.symbol
    when :js
      rescue_for_js_content_type(exception)
    when :rdf, :xml
      rescue_for_rdf_content_type(exception)
    else
      if request.headers['Content-Type'] and request.headers['Content-Type'].include?('application/rdf+xml')
        rescue_for_rdf_content_type(exception)
      else
        redirect_to root_url, alert: exception.message
      end
    end
  end

  def rescue_for_rdf_content_type(exception)
    if current_user
      message = "#{t(:you_dont_have_permission_to, scope: [:controllers, :application])} #{exception.action} #{exception.subject.class.to_s.pluralize}"
      render text: ::Oslc::Error.new(403, message).to_rdfxml, status: 403
    else
      render text: ::Oslc::Error.new(401, exception.message).to_rdfxml, status: 401
    end
  end

  def rescue_for_js_content_type(exception)
    if signed_in?
      render '/statuses/403', status: 403, :message => "#{t(:you_dont_have_permission_to, scope: [:controllers, :application])} #{exception.action} #{exception.subject.class.to_s.pluralize}"
    else
      # render '/statuses/401', status: 401, :message => "You must be logged in to do that!"
      redirect_to root_url, :alert => exception.message
    end
  end

  # Handle error exceptions
  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.html { render html: {file: 'public/500.html'},
        status: 500
      }
      format.json { render json: {error: "#{t(:internal_server_error, scope: [:controllers, :application])} #{exception.message}"}.to_json,
        status: 500
      }
    end
  end

  def set_request_url
    @request_url = request.url
  end

  def set_request_path
    @request_path = request.path
  end

  private

  protected

  def translate(name, object)
    object_name = object.class.name.split('::').last
    object_name = object_name.scan(/([A-Z][a-z]*)/).flatten.join(' ')
    object_name = 'Branch' if object_name == 'Set'
    if name == :successfully_created
      t(:was_successfully_created, scope: [:controllers, :application], name: object_name)
    elsif name == :successfully_updated
      t(:was_successfully_updated, scope: [:controllers, :application], name: object_name)
    elsif name == :successfully_destroyed
      t(:was_successfully_destroyed, scope: [:controllers, :application], name: object_name)
    elsif name == :successfully_cloned
      t(:was_successfully_cloned, scope: [:controllers, :application], name: object_name)
    elsif name == :successfully_closed
      t(:was_successfully_closed, scope: [:controllers, :application], name: object_name)
    end
  end

  def http_basic_authenticate
    if current_user
      @current_user = current_user
    else
      authenticate_or_request_with_http_basic do |email, password|
        user = ::User.where(email: email).first
        if user and user.valid_password?(password)
          @current_user = user
        else
          false
        end
      end
    end
  end

  def js_redirect_to(url)
    render js: %(window.location.href='#{url}') and return
  end

  def js_reload_page
    render js: %(window.location.reload()) and return
  end

  # when object is deleted then we should redirect to forced_path
  # in other situation we should get :back
  def back_or_customize_url(object, forced_url)
    matcher = object.class.name.gsub(/.*::/, '').gsub(/([A-Z])/, '_\1').split('_').join('.*').downcase
    if request.referrer.nil? or URI(request.referrer).to_s =~ /#{matcher}.*/
      forced_url
    else
      :back
    end
  end

  # when some element of hash don't exist then we get nil value
  def nested_hash(hash, *args)
    result = hash
    args.each do |arg|
      result = result[arg]
    end
    result
  rescue
    nil
  end

  def current_member
    return @current_member if @current_member
    if @project.present? and current_user.present?
      @current_member = ::Tmt::Member.where(project: @project, user: current_user).first_or_create
      return @current_member
    end
    nil
  end

  def custom_fields_url(custom_field)
    if custom_field.kind_of?(Tmt::TestRunCustomField)
      admin_test_run_custom_fields_url
    elsif custom_field.kind_of?(Tmt::TestCaseCustomField)
      admin_test_case_custom_fields_url
    else
      nil
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |user|
      user.permit(:name, :email, :password, :password_confirmation)
    end

    devise_parameter_sanitizer.for(:account_update) do |user|
      user.permit(:name, :password, :password_confirmation, :current_password)
    end
  end

  def notice_successfully_created(object_or_name, type=nil)
    content = translate(:successfully_created, object_or_name)
    notice_content(content, type)
  end

  def notice_successfully_destroyed(object_or_name, type=nil)
    content = translate(:successfully_destroyed, object_or_name)
    notice_content(content, type)
  end

  def notice_successfully_updated(object_or_name, type=nil)
    content = translate(:successfully_updated, object_or_name)
    notice_content(content, type)
  end

  def notice_successfully_cloned(object_or_name, type=nil)
    content = translate(:successfully_cloned, object_or_name)
    notice_content(content, type)
  end

  def notice_successfully_closed(object_or_name, type=nil)
    content = translate(:successfully_closed, object_or_name)
    notice_content(content, type)
  end

  def notice_content(content, type=nil)
    format = request.format.symbol
    flash[:notice] = content if format == :html
    if type == :also_now
      flash.now[:notice] = content if format == :js
    end
  end

end

if Tmt.config[:expiration_date]
  class ApplicationController
    before_action :block_application
    def block_application
      if Time.now > Time.new(*Tmt.config[:expiration_date])
        redirect_to '/website-has-expired'
      end
    end
  end
end
