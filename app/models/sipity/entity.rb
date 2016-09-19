module Sipity
  # A proxy for the entity that is being processed.
  # By using a proxy, we need not worry about polluting the proxy's concerns
  # with things related to processing.
  #
  # The goal is to keep this behavior separate, so that we can possibly
  # extract the information.
  class Entity < ActiveRecord::Base
    self.table_name = 'sipity_entities'

    # The proxy_for column holds a GlobalID string
    belongs_to :strategy
    belongs_to :strategy_state

    has_many :entity_specific_responsibilities, dependent: :destroy

    has_many :comments,
             foreign_key: :entity_id,
             dependent: :destroy,
             class_name: 'Sipity::Comment'

    delegate :name, to: :strategy_state, prefix: :strategy_state
    delegate :name, to: :strategy, prefix: :strategy
  end
end
