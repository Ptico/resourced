require "spec_helper"

describe Resourced::Resource do
  class ResourceModel
    def initialize
      @result = ""
    end
    attr_reader :result

    def method_missing(name, value)
      @result += "##{name}(#{value})"
      self
    end

    class << self
      def title(value)
        self.new.title(value)
      end

      def email(value)
        self.new.email(value)
      end
    end
  end

  class TestResource
    include Resourced::Resource

    model ResourceModel
    key :id

    attributes do
      allow :a, :b
      allow :c, :if => lambda { scope == :admin }
      restrict :b, :if => lambda { scope != :admin }
    end

    finders do
      finder :title do |v|
        chain.title(v)
      end

      finder :email, :if => lambda { scope == :admin } do |v|
        chain.email(v)
      end
    end
  end

  describe "Context independent properties" do
    let(:inst) { TestResource.new({}, :admin) }

    it "should store pkey" do
      inst.key.should eq(:id)
    end

    it "should store model" do
      inst.model.should eq(ResourceModel)
    end

    it "should store scope" do
      inst.scope.should eq(:admin)
    end
  end

  describe "Chain" do
    let(:inst) { TestResource.new({ :title => "John", :email => "test@test.com" }, role) }

    context "when scope not match" do
      let(:role) { :guest }

      it "should apply finders to the chain" do
        inst.apply_finders.chain.result.should eq("#title(John)")
      end

      it "should not rewrite model" do
        inst.apply_finders.model.should eq(ResourceModel)
      end
    end

    context "when scope is match" do
      let(:role) { :admin }

      it "should apply finders to the chain" do
        inst.apply_finders.chain.result.should eq("#title(John)#email(test@test.com)")
      end
    end
  end

  describe "Attributes" do
    let(:inst) { TestResource.new({ :a => "a", :b => "b", :c => "c" }, :user) }

    it "should filter attributes" do
      inst.attributes.should eq({ :a => "a"})
    end
  end

  describe "Finders" do
    let(:inst) { TestResource.new({ :title => "John", :email => "test@test.com" }) }

    it "should filter finders" do
      inst.finders.keys.should eq([:title])
    end
  end
end