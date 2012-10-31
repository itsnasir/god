module God
  module Conditions

    class DelayedJobExceededLimit < PollCondition
      attr_accessor :above, :pid_file, :env_file

      def initialize
        super
        self.above = nil
      end

      def pid
        self.pid_file ? File.read(self.pid_file).strip.to_i : self.watch.pid
      end

      def valid?
        valid = true
        valid &= complain("Attribute 'pid_file' must be specified", self) if self.pid_file.nil? && self.watch.pid_file.nil?
        valid &= complain("Attribute 'above' must be specified", self) if self.above.nil?
        valid &= complain("Attribute 'env_file' must be specified", self) if self.env_file.nil?
        valid
      end

      def test
        require self.env_file

        no_of_records = Delayed::Job.count

        if no_of_records > above
          self.info = "delayed job exceeds limit #{above}"
          return true
        else
          return false
        end
      end
    end

  end
end
