require_relative 'environment'

module GCP
  class Tasks
    include Rake::DSL

    def initialize
      namespace :gcp do
        GCP::Task::Config.new
        GCP::Task::Deploy.new
        GCP::Task::Console.new
        GCP::Task::Log.new
        GCP::Task::Storage.new
      end
    end
  end
end

## Define rake tasks
GCP::Tasks.new
