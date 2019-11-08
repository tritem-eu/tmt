module CanCanHelper
  def should_not_authorize(user=:no_logged, options={}, &block)

    user = case user
    when :foreign
      create(:user)
    when :no_logged
      nil
    else
      if user.class == User
        user
      else
        raise "Did not define key '#{user}'!"
      end
    end
    unless user.nil?
      if options[:auth] == :basic
        http_login user
      else
        sign_in user
      end
    end
    yield
    if options[:auth] == :basic
      response.should_not be_success
    else
      if user.nil?
        flash[:alert].should eq("You need to sign in or sign up before continuing.")
        response.should redirect_to(new_user_session_path)
      else
        flash[:alert].should eq("You are not authorized to access this page.")
        response.should redirect_to(root_path)
      end
    end
  end

  def cancan_not_authorize
    flash[:alert].should eq("You are not authorized to access this page.")
    response.should redirect_to(root_path)
  end

  def it_should_not_authorize(object, users, options={}, &block)
=begin
    object.context do
      users.each do |user_key|
        object.it "doesn't authorize when user is #{user_key}" do
          created_user = user_key.to_s.scan(/self\.(.*)/).flatten.first
          user_key = self.send(created_user) if created_user
          should_not_authorize(user_key, options) do
            instance_exec(options, &block)
          end
        end
      end
    end
=end
  end

  def rendered_view? options={}, &block
    block.call
    response.body.should match(/html/)
  end

end
