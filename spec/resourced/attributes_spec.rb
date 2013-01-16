require "spec_helper"

describe Resourced::Attributes do
  class AttributesTest
    include Resourced::Attributes

    def initialize(params, scope=nil)
      @scope = scope
      super
    end
    attr_reader :attributes
  end

  params = { :a => 1, :b => 2, :c => 3, :d => 4 }

  describe "Unconditional allows" do
    klass = AttributesTest.dup
    klass.attributes do
      allow :a, :b, :c
    end
    inst = klass.new(params, "admin")

    it "should contain only allowed" do
      inst.attributes.keys.should eq([:a, :b, :c])
    end
  end

  describe "Conditional allows" do
    klass = AttributesTest.dup

    klass.attributes do
      allow :a, :b, :c
      allow :d, :if => lambda { @scope == "admin" }
    end

    context "when condition matches" do
      inst = klass.new(params, "admin")

      it "should contain conditional param" do
        inst.attributes.keys.should eq([:a, :b, :c, :d])
      end
    end

    context "when condition not matches" do
      inst = klass.new(params, "guest")

      it "should not contain conditional param" do
        inst.attributes.keys.should eq([:a, :b, :c])
      end
    end
  end

  describe "Unconditional restricts" do
    klass = AttributesTest.dup
    klass.attributes do
      allow :a, :b, :c
      restrict :c
    end
    inst = klass.new(params, "admin")

    it "should not contain restricted" do
      inst.attributes.keys.should eq([:a, :b])
    end
  end

  describe "Conditional restricts" do
    klass = AttributesTest.dup
    klass.attributes do
      allow :a, :b, :c
      restrict :c, :if => lambda { @scope != "admin" }
    end

    context "when condition matches" do
      inst = klass.new(params, "guest")

      it "should not contain conditional param" do
        inst.attributes.keys.should eq([:a, :b])
      end
    end

    context "when condition not matches" do
      inst = klass.new(params, "admin")

      it "should contain conditional param" do
        inst.attributes.keys.should eq([:a, :b, :c])
      end
    end
  end

  describe "Attribute body" do
    klass = AttributesTest.dup
    klass.body :test
    klass.attributes do
      allow :a, :b
    end
    inst = klass.new({ :test => params })

    it "should get attributes from given body" do
      inst.attributes.keys.should eq([:a, :b])
    end
  end
end