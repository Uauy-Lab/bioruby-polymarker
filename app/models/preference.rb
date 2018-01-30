class Preference
  include Mongoid::Document
  field :key, type: String
  field :value, type: String
end
