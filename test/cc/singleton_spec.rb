require 'cc/singleton'

describe CC::Singleton do
  it "should return the same object when called with identical args" do
    a0 = Array.singleton
    a1 = Array.singleton([0,1,2])

    Array.singleton          << :foo
    Array.singleton([0,1,2]) << :bar

    Array.singleton.should == [:foo]
    Array.singleton([0,1,2]).should == [0,1,2,:bar]

    Array.singleton.object_id.should == a0.object_id
    Array.singleton([0,1,2]).object_id.should == a1.object_id
  end
end
