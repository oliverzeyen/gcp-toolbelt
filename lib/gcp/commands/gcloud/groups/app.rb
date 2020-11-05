module GCP
  module Command
    module Group
      module Gcloud
        class App < GCP::Command::Group::GroupBase
          GROUP = :app
          OPTIONS = ['--project', '--service', '--split-health-checks'].freeze
        end
      end
    end
  end
end
