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

  class User < ActiveRecord::Base; end;

  let(:klass) do
    Class.new do
      include Resourced::ActiveRecord

      model User
      key :id

      params do
        allow :name, :email
        allow :role, :if => lambda { scope == "admin" }
      end

      finders do
        finder :name do |v|
          chain.where(:name => v)
        end
      end
    end
  end

  describe "Create" do
    it "should filter params" do
      inst  = klass.new({ :name => "Peter", :email => "peter@test.com", :role => "admin" }, "")
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

    it "should find by pkey" do
      inst = klass.new({ :id => 3 }, "")

      inst.first.name.should eq("Lisa")
    end

    it "should find with finder" do
      inst = klass.new({ :name => "Bart" }, "")

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

  describe "Update" do
    before :each do
      add_user 1, "Homer", "homer@test.com", "admin"
      add_user 2, "Bart", "bart@test.com", "user"
      add_user 3, "Lisa", "lisa@test.com", "user"
    end

    it "should prepare collection to update" do
      inst = klass.new({ :id => [2, 3], :role => "guest" }, "admin")

      collection = inst.update

      collection.map{ |u| u.role }.should eq(["guest", "guest"])
    end

    it "should update the record immediatly" do
      inst = klass.new({ :id => [2, 3], :role => "guest" }, "admin")

      inst.update!

      User.find(2).role.should eq("guest")
      User.find(3).role.should eq("guest")
    end
  end

end