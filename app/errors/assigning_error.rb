# frozen_string_literal: true

module AssigningError
  class Base < StandardError; end
  class AlreadyUsedOnUser < Base; end
  class AlreadyUsedOnOtherUser < Base; end
  class DeviceNotFound < Base; end
  class NotAssigned < Base; end
end