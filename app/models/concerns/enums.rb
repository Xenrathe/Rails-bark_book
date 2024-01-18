module Enums
  extend ActiveSupport::Concern

  included do
    enum dog_size: { small: 0, large: 1, both: 2 }, _default: 'both'
  end
end