class Location < ActiveRecord::Base
  [ :raw_location,
    :lat,
    :lng,
    :city,
    :province,
    :state,
    :zip,
    :country,
    :country_code,
    :accuracy,
    :precision,
    :suggested_bounds,
    :provider
  ].each do |attr|
    validates attr, :presence => true
  end
  
  validate :accuracy_cannot_be_zero
  validate :precision_cannot_be_unknown
  
private
  # The error messages here aren't that meaningful, but it doesn't matter since aren't using them anyway
  def accuracy_cannot_be_zero
    self.errors.add(:accuracy, "cannot be zero") if accuracy == 0
  end
  def precision_cannot_be_unknown
    self.errors.add(:precision, "cannot be unknown") if precision == "unknown"
  end
end# == Schema Information
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

