desc 'Run rubocop as part of default rake'
task :default do
  Rake::Task['rubocop'].invoke
end
