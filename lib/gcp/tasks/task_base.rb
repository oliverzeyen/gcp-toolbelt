module GCP
  module Task
    class TaskBase
      # Include Rake::DSL to have access to the task DSL
      include Rake::DSL

      def initialize
        tasks
      end

      def config
        @config ||= GCP::Helper::Config.new
      end

      def shell
        @shell ||= GCP::Helper::Shell.new
      end

      def gsutil
        @gsutil ||= GCP::Command::Gsutil.new
      end

      def gcloud
        @gcloud ||= GCP::Command::Gcloud.new
      end

    end
  end
end
