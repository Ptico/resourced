require "spec_helper"
require "support/active_record"

require "active_record"
require "resourced/active_record"

describe Resourced::ActiveRecord do
  before :each do
    setup_db
  end

  after :each do
    teardown_db
  end

  class User < ActiveRecord::Base; end

  let(:klass) do
    Class.new do
      include Resourced::ActiveRecord

      model User
      body :user
      key  :id

      attributes do
        allow :name, :email
        allow :role, :if => lambda { scope == "admin" }
      end

      finders do
        finder :search do |val|
          chain = self.chain
          chain = chain.where(:name => val[:name]) if val[:name].present?
          chain = chain.where(:email => val[:email]) if val[:email].present?
          chain
        end
      end
    end
  end

  describe "Create" do
    it "should filter params" do
      inst  = klass.new({ :user => { :name => "Peter", :email => "peter@test.com", :role => "admin" } }, "")
      attrs = inst.build.attributes

      attrs["name"].should eq("Peter")
      attrs["role"].should be_nil
    end
  end

  describe "Read" do
    before :each do
      add_user 1, "Homer", "homer@test.com", "admin"
      add_user 2, "Bart", "bart@test.com", "user"
      add_user 3, "Lisa", "lisa@test.com", "user"
    end

    describe 'Filtering data by init params' do

      it "should find by pkey" do
        inst = klass.new({ :id => 3 }, "")

        inst.first.name.should eq("Lisa")
      end

      it "finds with finder" do
        inst = klass.new({search: { :name => "Bart" }}, "")

        inst.first.email.should eq("bart@test.com")
      end

      it "should find with attribute" do
        inst = klass.new({user: { :name => "Bart" }}, "")

        inst.first.email.should eq("bart@test.com")
      end

      it "should iterate over results with #map" do
        inst = klass.new({}, "")

        result = inst.map do |user|
          user.name
        end

        result.should eq(%w(Homer Bart Lisa))
      end
    end

    describe 'searching by finders' do
      before :each do
        @inst = klass.new({}, "")
      end

      it 'searches by :name finder' do
        search = @inst.set(search: {name: 'Homer'}).all

        search.size.should eq(1)
        search.first.name.should eq("Homer")
        search.first.email.should eq("homer@test.com")
      end

      it 'searches by :name finder using array' do
        search = @inst.set(search: {name: ['Homer', 'Lisa']}).all

        search.size.should eq(2)
        search.first.name.should eq("Homer")
        search.first.email.should eq("homer@test.com")

        search.last.name.should eq("Lisa")
        search.last.email.should eq("lisa@test.com")
      end

      it 'searches by :email finder using match' do
        search = @inst.set(search: {email: 'li%@test%'}).all

        search.size.should eq(2)
        search.first.name.should eq("Homer")
        search.first.email.should eq("homer@test.com")

        search.last.name.should eq("Lisa")
        search.last.email.should eq("lisa@test.com")
      end

      it 'searches by finder without val' do
        search = @inst.set(search: {}).all

        search.should be_nil
      end
    end
  end

  describe "Update" do
    before :each do
      add_user 1, "Homer", "homer@test.com", "admin"
      add_user 2, "Bart", "bart@test.com", "user"
      add_user 3, "Lisa", "lisa@test.com", "user"
    end

    it "should prepare collection to update" do
      inst = klass.new({ :id => [2, 3], :user => { :role => "guest" } }, "admin")

      collection = inst.update

      collection.map{ |u| u.role }.should eq(["guest", "guest"])
    end

    it "should update the record immediatly" do
      inst = klass.new({ :id => [2, 3], :user => { :role => "guest" } }, "admin")

      inst.update!

      User.find(2).role.should eq("guest")
      User.find(3).role.should eq("guest")
    end
  end

end