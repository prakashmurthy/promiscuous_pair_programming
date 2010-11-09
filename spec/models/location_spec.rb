require File.expand_path('../../spec_helper', __FILE__)

describe Location do
  subject { Factory.build(:location) }
  
  context "validations" do
    (PPP::ModelMixins::Geolocation::GEOLOC_ATTRIBUTES - [:street_address, :district, :zip]).each do |attr|
      it "always requires #{attr} to be filled in" do
        subject.send("#{attr}=", nil)
        expect { subject.save }.to raise_error(ActiveRecord::StatementInvalid, /^PGError: ERROR:  null value in column/)
      end
    end
  end 
end