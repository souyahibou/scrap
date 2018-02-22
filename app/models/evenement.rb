require 'active_record/diff'

class Evenement < ApplicationRecord
    include ActiveRecord::Diff
end
