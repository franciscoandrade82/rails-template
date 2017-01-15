RAILS_REQUIREMENT = "~> 5.0.1"

def apply_template!
  start_message
  assert_minimum_rails_version
  #assert_valid_options
  #assert_postgresql
  add_template_repository_to_source_path

  template "Gemfile.tt",   :force => true
  template "README.md.tt", :force => true
  
  rails_command "g devise:install"
  rails_command "g devise user -e"

  rails_command "db:migrate"

  rails_command "g devise:views user -e"
  rails_command "g controller home index -e"

  # add first language, remember to copy helper and application controller
  rails_command "gettext:add_language LANGUAGE=en"

  directory "config", "config", :force => true

  directory "app/assets/javascripts", "app/assets/javascripts", :force => true
  directory "app/assets/stylesheets", "app/assets/stylesheets", :force => true
  
  directory "app/controllers", "app/controllers", :force => true
  
  directory "app/helpers", "app/helpers", :force => true
  
  directory "app/views", "app/views", :force => true
end

def start_message
  puts '================================================================'
  puts '=  Start configuring your application -> ' + app_name
  puts '================================================================'
end

#
# copied from https://github.com/mattbrictson
#
def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

#
# copied from https://github.com/mattbrictson
#
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git :clone => [
      "--quiet",
      "https://github.com/mattbrictson/rails-template.git",
      tempdir
    ].map(&:shellescape).join(" ")
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

# apply the template
apply_template!