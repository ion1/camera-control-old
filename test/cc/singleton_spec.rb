# camera-control – Control Sanyo PTZ cameras with a custom input board
# Copyright © 2008 Johan Kiviniemi
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

require 'cc/singleton'

describe CC::Singleton do
  before :each do
    # Reset the state.
    CC::Singleton.module_eval '@@singletons = nil'
  end

  it "should return the same object when called with identical args" do
    a0 = Array.singleton
    a1 = Array.singleton([0,1,2])

    Array.singleton          << :foo
    Array.singleton([0,1,2]) << :bar

    Array.singleton         .should == [:foo]
    Array.singleton([0,1,2]).should == [0,1,2,:bar]

    Array.singleton.object_id         .should == a0.object_id
    Array.singleton([0,1,2]).object_id.should == a1.object_id
  end
end
