require 'yaml'

module GCP
  module Helper
    class Config
      DEPLOY_FILE_SUFFIX = '.yaml'.freeze
      SAVE_DEPLOY_FILE_SUFFIX = '-IGNORED.yaml'.freeze
      FILE_LOCATION = Rails.root
      FILE_NAME = 'gcp_config.yml'.freeze
      DEFAULT =
        {
          'sql_dump_download_dir' => './',
          'production' => {
            'db_export_bucket' => 'unique-db-dump-bucket-name',
            'db_import_bucket' => 'unique-import-dump-bucket-name',
            'project' => 'app-engine-production',
            'services' => {
              'app' => 'default',
              'worker' => 'worker'
            }
          },
          'staging' => {
            'db_export_bucket' => 'unique-db-dump-bucket-name',
            'db_import_bucket' => 'unique-import-dump-bucket-name',
            'project' => 'app-engine-staging',
            'services' => {
              'app' => 'default',
              'worker' => 'worker'
            }
          }
        }.freeze

      def initialize; end

      def data
        return unless config_file_exist?

        YAML.safe_load(File.open(Rails.root.join(FILE_NAME), "r").read).with_indifferent_access
      end

      def create_default_config
        return if config_file_exist?

        File.open(FILE_LOCATION.join(FILE_NAME), "w+") do |file|
          file.write(DFEAULT.to_yaml)
        end
      end

      def deploy_files_to_s(project_env, target_services, suffix = SAVE_DEPLOY_FILE_SUFFIX)
        deploy_files_to_a(project_env, target_services, suffix).map do |file|
          file + suffix
        end.join(' ')
      end

      def create_save_deploy_files
        
      end

      private

      def deploy_files_to_a(project_env, target_services, suffix = SAVE_DEPLOY_FILE_SUFFIX)
        target_services.map do |service_name|
          target_service = data[project_env][:services][service_name]
          "#{target_service}-#{project_env}"
        end
      end

      def check_gitignore
        production_deploy_files = deploy_file_names(:production, [:app, :worker])
        staging_deploy_files = deploy_file_names(:production, [:app, :worker])

        shell.execute(format('git check-ignore %s', ))
      end

      def config_file_exist?
        FILE_LOCATION.join(FILE_NAME).exist?
      end

    end
  end
end
