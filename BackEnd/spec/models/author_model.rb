require 'rails_helper'

RSpec.describe "Author Class", type: :model do
  describe "Check Author class Business Rules" do
    context "when the Author has the right parameters" do
      it "It should be created" do
        expect {
            Author.new("Sara Camussa","12345678",1,1,"www.myhome.com","www.myurl.com")
            }.not_to raise_error(ArgumentError)              
      end      
    end

    context "when the Author has null name or empty string name" do
        it "It should not be created" do
          expect {
              Author.new("","12345678",1,1,"www.myhome.com","www.myurl.com")
              }.to raise_error(ArgumentError)              
        end      
      end
  end

  context "when the Author has a number of citations negative" do
    it "It should not be created" do
      expect {
          Author.new("Sara Camussa","12345678",1,-1,"www.myhome.com","www.myurl.com")
          }.to raise_error(ArgumentError)              
    end      
  end 

  context "when the Author has a number of papers negative" do
    it "It should not be created" do
      expect {
          Author.new("Sara Camussa","12345678",-1,1,"www.myhome.com","www.myurl.com")
          }.to raise_error(ArgumentError)              
    end      
  end  

  context "when the Author has an Id null or empty" do
    it "It should not be created" do
      expect {
          Author.new("Sara Camussa","",1,1,"www.myhome.com","www.myurl.com")
          }.to raise_error(ArgumentError)              
    end      
  end 

  context "when the Author has url and homepage empty" do
    it "It should  be created" do
      expect {
          Author.new("Sara Camussa","12345678",1,1,"","")
          }.not_to raise_error               
    end      
  end     
end

