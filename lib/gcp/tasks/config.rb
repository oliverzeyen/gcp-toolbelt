module GCP
  module Task
    class Config < TaskBase

      private

      def tasks
        task init: 'config:init'
        namespace :config do
          task :init do
            config.create_default_config
          end
        end
      end
      
    end
  end
end
