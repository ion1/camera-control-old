require 'cc/callbacks'

describe CC::Callbacks do
  before :each do
    @cb = CC::Callbacks.new
  end

  it "should run all callbacks in order" do
    ary = []

    @cb.add do |arg|
      ary << :foo
    end

    @cb.add do |arg|
      ary << arg
    end

    @cb.call :bar

    ary.should == [:foo, :bar]
  end
end
