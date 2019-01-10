=begin
    The 'require' definitions define which gems dependencies our script needs. In this example we have
    - The selenium-webdriver gem
    - The rspec framework gem
    - The sauce_whisk gem (a wrapper for the SauceLabs REST API)
=end
require "selenium-webdriver"
require "rspec"
require "sauce_whisk"
=begin
    The basic structure of RSpec uses 'describe' and 'it' to format our script in a conversational tone.
    'describe' represents the highest context, for example if we were testing authentication features it would say something like: '.authentication', and the 'it' would say something like 'should login'
=end
describe "Instant Sauce Labs RSpec Test" do

=begin
    'before is an RSpec method that allows us to define prerequisite test execution steps such as:
        - defining the browser name
        - defining the browser version
        - defining the OS version and platform
        - defining the sauce:options capabilities, in this case the test name, the SauceLabs credentials, and the selenium version
=end

  before(:each) do |test|
    caps = {
        browser_name: 'chrome',
        platform_version: 'Windows 10',
        browser_version: '61.0',
        "goog:chromeOptions": {w3c: true},
        "sauce:options" => {
            name: test.full_description,
            seleniumVersion: '3.11.0',
            username: ENV['SAUCE_USERNAME'],
            accessKey: ENV['SAUCE_ACCESS_KEY']
        }
    }
    @driver = Selenium::WebDriver.for(:remote,
                                     url: 'https://ondemand.saucelabs.com:443/wd/hub',
                                     desired_capabilities: caps)
  end
=begin
    Again, 'it' represents the business-level logic that we're testing, in this case we're checking to see if our test in SauceLabs session can open Chrome using W3C, then check the title page.
=end
  it "should_open_chrome" do
    @driver.get('https://www.saucedemo.com')
    puts "title of webpage is: #{@driver.title}"
  end
=begin
    Here we use 'after' which is another RSpec method that handles all postrequisite test execution steps such as:
        - sending the results to SauceLabs.com
        - Tearing down the current RemoteWebDriver session so that the test VM doesn't hang
=end
  after(:each) do |example|
    SauceWhisk::Jobs.change_status(@driver.session_id, !example.exception)
    @driver.quit
  end
end