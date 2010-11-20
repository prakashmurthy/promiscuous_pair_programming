class Location < ActiveRecord::Base
end
# == Schema Information
#
# Table name: locations
#
#  id               :integer         not null, primary key
#  raw_location     :string(255)     not null
#  lat              :float           not null
#  lng              :float           not null
#  street_address   :string(255)
#  city             :string(255)     not null
#  province         :string(255)     not null
#  district         :string(255)
#  state            :string(255)     not null
#  zip              :string(255)
#  country          :string(255)     not null
#  country_code     :string(255)     not null
#  accuracy         :integer         not null
#  precision        :string(255)     not null
#  suggested_bounds :string(255)     not null
#  provider         :string(255)     not null
#  created_at       :datetime
#  updated_at       :datetime
#

