class AppBuilder < Rails::AppBuilder

  def cwd
    File.dirname(File.expand_path(__FILE__))
  end

  def readme
  end

  def gitignore
    copy_file cwd + "/templates/gitignore", ".gitignore"
  end
  
end