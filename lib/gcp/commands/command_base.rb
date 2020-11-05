module GCP
  module Command
    class CommandBase

      def initialize
      end

      def shell
        @shell ||= GCP::Helper::Shell.new
      end

      private

      def to_executable(command, *options)
        return [self.class::EXECUTABLE, command, options].join(' ')
      end
    end
  end
end
