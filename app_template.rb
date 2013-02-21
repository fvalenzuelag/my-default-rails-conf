def cwd
  File.dirname(File.expand_path(__FILE__))
end

remove_dir "doc"
remove_dir "log"
remove_dir "tmp"
remove_dir "vendor/plugins"

remove_file "app/assets/images/rails.png"
remove_file "README.rdoc"
remove_file "public/index.html"

# Setting up the database
create_file "config/database.yml.sample" do
<<-EOS
production:
  adapter: postgresql
  encoding: unicode
  database: app_prod
  pool: 5
  username: rodrigo
  password: rodrigo
  host: localhost
  port: 5432
  schema_search_path: public
  min_messages: error
development:
  adapter: postgresql
  encoding: unicode
  database: app_dev
  pool: 5
  username: rodrigo
  password: rodrigo
  host: localhost
  port: 5432
  schema_search_path: public
  min_messages: notice
test:
  adapter: postgresql
  encoding: unicode
  database: app_test
  pool: 5
  username: rodrigo
  password: rodrigo
  host: localhost
  port: 5432
  schema_search_path: public
  min_messages: warning
EOS
end

run "cp config/database.yml config/database.yml.project"
run "cp config/database.yml.sample config/database.yml"
run "$EDITOR config/database.yml"

rake "db:drop:all"
rake "db:create:all"

# Installing the default server I want
gem "libv8"
gem "unicorn"
gem "sprinkle"
gem "capistrano"

run "bundle install"
run "capify ."

copy_file cwd + "/templates/install.rb", "config/install.rb"
remove_file "config/deploy.rb"
copy_file cwd + "/templates/deploy.rb", "config/deploy.rb"

# Securing the secret token
gsub_file "config/initializers/secret_token.rb", /config.secret_token = (.+)$/, "config.secret_token = File.read(File.join(File.dirname(__FILE__), '..', 'security_token')).strip"
run "rake secret >> config/security_token"

# Disabling stylesheet generation
inject_into_file "config/application.rb", :after => "config.filter_parameters += [:password]" do
<<-TEXT
# Customize generators

    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.test_framework :rspec,
        :fixtures => true,
        :view_specs => false,
        :helper_specs => false,
        :routing_specs => false,
        :controller_specs => true,
        :request_specs => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end
TEXT
end

# Avoiding to initialize Rails on assets precompiling
inject_into_file "config/application.rb", :after => "config.assets.enabled = true" do
<<-TEXT

    config.assets.initialize_on_precompile = false
TEXT
end

# Enabling database-related gems
gem "composite_primary_keys"
gem "foreigner"
gem "immigrant"
gem "awesome_nested_set"
gem "paperclip"
gem "bcrypt-ruby"
gem "state_machine"
gem "globalize3"

run "bundle install"

# Enabling authentication and authorization-related gems
gem "devise"
gem "devise-encryptable"
gem "cancan"

run "bundle install"
run "echo 'config/database.yml' >> .gitignore"

generate "devise:install"
gsub_file "config/initializers/devise.rb", /please-change-me-at-config-initializers-devise@example.com/, "rfuentealbac.83@gmail.com"
gsub_file "config/initializers/devise.rb", "# config.authentication_keys = [ :email ]", "config.authentication_keys = [ :email ]"
gsub_file "config/initializers/devise.rb", "# config.paranoid = true", "config.paranoid = true"
gsub_file 'config/initializers/devise.rb', /# config.pepper(.*)/, "config.pepper = File.read(File.join(File.dirname(__FILE__), '..', 'devise_pepper')).strip"
gsub_file 'config/initializers/devise.rb', '# config.confirmation_keys = [ :email ]', 'config.confirmation_keys = [ :email ]'
gsub_file 'config/initializers/devise.rb', /# config.remember_for = 2.weeks/, 'config.remember_for = 4.weeks'
gsub_file 'config/initializers/devise.rb', /# config.password_length = 6..128/, 'config.password_length = 6..128'
gsub_file 'config/initializers/devise.rb', /# config.timeout_in = 30.minutes/, 'config.timeout_in = 2.hours'
gsub_file 'config/initializers/devise.rb', /# config.maximum_attempts = 20/, 'config.maximum_attempts = 5'
gsub_file 'config/initializers/devise.rb', /# config.encryptor = :sha512/, 'config.encryptor = :sha512'
gsub_file 'config/initializers/devise.rb', /# config.token_authentication_key = :auth_token/, 'config.token_authentication_key = :auth_token'
run "rake secret > config/devise_pepper"

inject_into_file "config/environments/development.rb", :after => "config.action_mailer.raise_delivery_errors = false" do
<<-EOS

  config.action_mailer.default_url_options = { :host => '127.0.0.1:3000' }
EOS
end

inject_into_file "app/controllers/application_controller.rb", :after => "protect_from_forgery" do
<<-TEXT

  # before_filter :set_current_user :authenticate_user!
  around_filter :enable_request_on_models!

  def enable_request_on_models!
    method_for_request = instance_variable_get(:"@_request") 

    ActiveRecord::Base.send(:define_method, "request", proc { method_for_request })
    ActiveRecord::Base.class.send(:define_method, "request", proc { method_for_request })
    yield
    ActiveRecord::Base.send :remove_method, "request"
    ActiveRecord::Base.class.send :remove_method, "request"
  end

  # Put this in your models!
  # def set_current_user!
  #   self.user_id ||= Thread.current[:user].id
  # end

  #def set_current_user
  #  Thread.current[:user] = current_user
  #end
TEXT
end

# Enabling layout-related gems
gem "nokogiri"
gem "simple_form"
gem "country_select"
gem "jbuilder"
gem "kaminari"
gem "rabl"

run "bundle install"
generate "simple_form:install"
generate "kaminari:config"

# Enabling mail-related gems
gem "premailer-rails3"
gem "mail"

run "bundle install"

# Enabling test-related gems
gem "ruby_parser", :group => :development
gem "bullet", :group => :development
gem "better_errors", :group => :development
gem "binding_of_caller", :group => :development
gem "ruby_gntp", :group => :development
gem "rspec-rails", :group => :development
gem "rspec-rails-mocha", :group => :development
gem "factory_girl_rails", :group => :development

gem "rspec-rails", :group => :test
gem "rspec-rails-mocha", :group => :test
gem "factory_girl_rails", :group => :test
gem "webrat", :group => :test
gem "ffaker", :group => :test
gem "capybara", :group => :test
gem "guard-rspec", :group => :test
gem "launchy", :group => :test
gem "database_cleaner", :group => :test

create_file "config/initializers/bullet.rb" do 
<<-TEXT
if defined? Bullet
  Bullet.enable = true
  Bullet.growl = true
end
TEXT
end

run "bundle install"
generate "rspec:install"

inject_into_file "spec/spec_helper.rb", :after => "require 'rspec/autorun'" do
<<-TEXT
require 'capybara/rspec'
require 'database_cleaner'
TEXT
end

inject_into_file ".rspec", :after => "--color" do
<<-TEXT
--format documentation
TEXT
end

# Creating a default file to install database triggers
create_file "db/triggers.sql"

# Creating initial controller
generate "controller home index"
gsub_file "config/routes.rb", 'get "home/index"', ''
route "root :to => 'home#index'"

rake "db:migrate:all"

git :init
git :add => "."
git :commit => "-a -m 'Initializing Application Structure.'"
