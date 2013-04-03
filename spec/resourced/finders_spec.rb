require "spec_helper"

describe Resourced::Finders do
  class FindersTestRelation
    def initialize
      @result = ""
    end
    attr_reader :result

    def method_missing(name, value)
      @result += "##{name}(#{value})"
      self
    end
  end

  # Workaround
  class FinderSuper; def initialize(*args); end; end

  let(:klass) {
    Class.new(FinderSuper) do
      include Resourced::Finders

      def initialize(params={}, scope="guest")
        super
        @scope = scope
        @chain = FindersTestRelation.new
      end
      attr_reader :chain
    end
  }
  let(:inst) { klass.new(params) }

  describe "Basic finder" do
    before :each do
      klass.finders do
        finder :offset do |val|
          chain.offset(val)
        end
      end
    end

    context "with given corresponding parameters" do
      let(:params) { {:offset => 2} }

      it "should be called" do
        inst.apply_finders.chain.result.should eq("#offset(2)")
      end
    end

    context "without corresponding parameters" do
      let(:params) { {} }

      it "should not be called" do
        inst.apply_finders.chain.result.should eq("")
      end
    end

    context "with corresponding parameters which are blank" do
      let(:params) { {offset: {} } }

      it "should be called" do
        inst.apply_finders.chain.result.should eq("#offset({})")
      end
    end
  end

  describe "Finder with default" do
    before :each do
      klass.finders do
        finder :limit, :default => 10 do |val|
          chain.limit(val)
        end
      end
    end

    context "when finder not specified" do
      let(:params) { {} }

      it { inst.apply_finders.chain.result.should eq("#limit(10)") }
    end

    context "when finder specified" do
      let(:params) { {:limit => 20} }

      it { inst.apply_finders.chain.result.should eq("#limit(20)") }
    end
  end

  describe "Default finder" do
    before :each do
      klass.default_finder do
        chain.default("foo")
      end
    end
    let(:params) { {} }

    it "should apply default finder" do
      inst.apply_finders.chain.result.should eq("#default(foo)")
    end
  end

end