require "spec_helper"

describe Resourced::Params do
  class ParamsTest
    include Resourced::Params

    def initialize(params, scope)
      @scope = scope
      super
    end
    attr_reader :params
  end

  params = { :a => 1, :b => 2, :c => 3, :d => 4 }

  describe "Unconditional allows" do
    klass = ParamsTest.dup
    klass.params do
      allow :a, :b, :c
    end
    inst = klass.new(params, "admin")

    it "should contain only allowed" do
      inst.params.keys.should eq([:a, :b, :c])
    end
  end

  describe "Conditional allows" do
    klass = ParamsTest.dup

    klass.params do
      allow :a, :b, :c
      allow :d, :if => lambda { @scope == "admin" }
    end

    context "when condition matches" do
      inst = klass.new(params, "admin")

      it "should contain conditional param" do
        inst.params.keys.should eq([:a, :b, :c, :d])
      end
    end

    context "when condition not matches" do
      inst = klass.new(params, "guest")

      it "should not contain conditional param" do
        inst.params.keys.should eq([:a, :b, :c])
      end
    end
  end

  describe "Unconditional restricts" do
    klass = ParamsTest.dup
    klass.params do
      allow :a, :b, :c
      restrict :c
    end
    inst = klass.new(params, "admin")

    it "should not contain restricted" do
      inst.params.keys.should eq([:a, :b])
    end
  end

  describe "Conditional restricts" do
    klass = ParamsTest.dup
    klass.params do
      allow :a, :b, :c
      restrict :c, :if => lambda { @scope != "admin" }
    end

    context "when condition matches" do
      inst = klass.new(params, "guest")

      it "should not contain conditional param" do
        inst.params.keys.should eq([:a, :b])
      end
    end

    context "when condition not matches" do
      inst = klass.new(params, "admin")

      it "should contain conditional param" do
        inst.params.keys.should eq([:a, :b, :c])
      end
    end
  end
end