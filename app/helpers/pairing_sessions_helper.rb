module PairingSessionsHelper
  def pair_information_for(pair)
    return "None" unless pair.present?
    "#{pair.full_name} (#{pair.email})"
  end
end
