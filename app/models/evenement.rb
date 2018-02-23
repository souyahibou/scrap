require 'active_record/diff'

class Evenement < ApplicationRecord
    include ActiveRecord::Diff
    validates_uniqueness_of :event_id, scope: [:origin_base]
end
