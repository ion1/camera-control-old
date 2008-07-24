require 'cc/callbacks'

describe CC::Callbacks do
  it "should run all callbacks in order" do
    ary = []

    c = CC::Callbacks.new

    c.add do |arg|
      ary << :foo
    end

    c.add do |arg|
      ary << arg
    end

    c.call :bar

    ary.should == [:foo, :bar]
  end
end
