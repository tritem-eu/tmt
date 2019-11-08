module FeaturesHelper
  include Capybara::DSL

  def js_exec(content)
    page.execute_script("$(function(){#{content}})")
  end

  def js_inject(content)
    page.execute_script(content)
  end

  def js_stoper(content)
    js_exec(%Q|
      $('div.rspec-lock').remove()
    |)

    5.times.each do |item|
      js_inject(%Q|
        if ($(#{content}).length){
          $('body').append("<div class='rspec-lock'></div>")
        }
      |)
      break if page.body.match('rspec-lock')
    end
  end

  def find_element(selector)
    page.driver.browser.find_element(:css => selector)
  end

end

RSpec.configure do |config|
  config.include FeaturesHelper, :type => :feature
end
