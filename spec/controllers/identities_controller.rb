require_relative '../spec_helper'

describe Api::V1::IdentitiesController do

  describe "GET index to get list of identities" do

  end

  describe "GET show to get details of an identity" do

  end

  describe "POST to create" do
    it "should change the number of identities" do

    end
  end

  describe "DELETE to remove" do
    it "should change the number of identities" do
      FactoryGirl.create :identity
      Identity.count.should == 1

      lambda { delete :destroy, id: Identity.last.id, token: ApiKey.last.access_token }.
        should change(Identity, :count).by(-1)

      response.code.should == '200'

      Identity.count.should == 0
    end

    it 'should return an error when trying to remove other usere\'s identity' do
      FactoryGirl.create :identity
      Identity.count.should == 1

      lambda { delete :destroy, id: Identity.last.id, token: 'wrong_token' }.
        should change(Identity, :count).by(0)

      response.code.should == '401'

      Identity.count.should == 1
    end
  end
end
