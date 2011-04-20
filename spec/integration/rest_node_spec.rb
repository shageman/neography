require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "get_root" do
    it "can get the root node" do
      root_node = @neo.get_root
      root_node.should have_key("self")
      root_node["self"].split('/').last.should == "0"
    end
  end

  describe "create_node" do
    it "can create an empty node" do
      new_node = @neo.create_node
      new_node.should_not be_nil
    end

    it "can create a node with one property" do
      new_node = @neo.create_node("name" => "Max")
      new_node["data"]["name"].should == "Max"
    end

    it "can create a node with more than one property" do
      new_node = @neo.create_node("age" => 31, "name" => "Max")
      new_node["data"]["name"].should == "Max"
      new_node["data"]["age"].should == 31
    end
  end

  describe "get_node" do
    it "can get a node that exists" do
      new_node = @neo.create_node
      new_node[:id] = new_node["self"].split('/').last
      existing_node = @neo.get_node(new_node)
      existing_node.should_not be_nil
      existing_node.should have_key("self")
      existing_node["self"].split('/').last.should == new_node[:id]
    end

    it "returns nil if it tries to get a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      existing_node = @neo.get_node(fake_node)
      existing_node.should be_nil
    end
  end

  describe "set_node_properties" do
    it "can set a node's properties" do
      new_node = @neo.create_node
      @neo.set_node_properties(new_node, {"weight" => 200, "eyes" => "brown"})
      existing_node = @neo.get_node(new_node)
      existing_node["data"]["weight"].should == 200
      existing_node["data"]["eyes"].should == "brown"
    end

    it "it fails to set properties on a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      @neo.set_node_properties(fake_node, {"weight" => 150, "hair" => "blonde"})
      node_properties = @neo.get_node_properties(fake_node)
      node_properties.should be_nil
    end
  end

  describe "reset_node_properties" do
    it "can reset a node's properties" do
      new_node = @neo.create_node
      @neo.set_node_properties(new_node, {"weight" => 200, "eyes" => "brown", "hair" => "black"})
      @neo.reset_node_properties(new_node, {"weight" => 190, "eyes" => "blue"})
      existing_node = @neo.get_node(new_node)
      existing_node["data"]["weight"].should == 190
      existing_node["data"]["eyes"].should == "blue"
      existing_node["data"]["hair"].should be_nil
    end

    it "it fails to reset properties on a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      @neo.reset_node_properties(fake_node, {"weight" => 170, "eyes" => "green"})
      node_properties = @neo.get_node_properties(fake_node)
      node_properties.should be_nil
    end
  end

  describe "get_node_properties" do
    it "can get all of a node's properties" do
      new_node = @neo.create_node("weight" => 200, "eyes" => "brown")
      node_properties = @neo.get_node_properties(new_node)
      node_properties["weight"].should == 200
      node_properties["eyes"].should == "brown"
    end

    it "can get some of a node's properties" do
      new_node = @neo.create_node("weight" => 200, "eyes" => "brown", "height" => "2m")
      node_properties = @neo.get_node_properties(new_node, ["weight", "height"])
      node_properties["weight"].should == 200
      node_properties["height"].should == "2m"
      node_properties["eyes"].should be_nil
    end

    it "returns nil if it gets the properties on a node that does not have any" do
      new_node = @neo.create_node
      @neo.get_node_properties(new_node).should be_nil
    end

    it "returns nil if it tries to get some of the properties on a node that does not have any" do
      new_node = @neo.create_node
      @neo.get_node_properties(new_node, ["weight", "height"]).should be_nil
    end

    it "returns nil if it fails to get properties on a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      @neo.get_node_properties(fake_node).should be_nil
    end
  end

  describe "remove_node_properties" do
    it "can remove a node's properties" do
      new_node = @neo.create_node("weight" => 200, "eyes" => "brown")
      @neo.remove_node_properties(new_node)
      @neo.get_node_properties(new_node).should be_nil
    end

    it "returns nil if it fails to remove the properties of a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      @neo.remove_node_properties(fake_node).should be_nil
    end

    it "can remove a specific node property" do
      new_node = @neo.create_node("weight" => 200, "eyes" => "brown")
      @neo.remove_node_properties(new_node, "weight")
      node_properties = @neo.get_node_properties(new_node)
      node_properties["weight"].should be_nil
      node_properties["eyes"].should == "brown"
    end

    it "can remove more than one property" do
      new_node = @neo.create_node("weight" => 200, "eyes" => "brown", "height" => "2m")
      @neo.remove_node_properties(new_node, ["weight", "eyes"])
      node_properties = @neo.get_node_properties(new_node)
      node_properties["weight"].should be_nil
      node_properties["eyes"].should be_nil
    end
  end

  describe "delete_node" do
    it "can delete an unrelated node" do
      new_node = @neo.create_node
      @neo.delete_node(new_node).should be_nil
      existing_node = @neo.get_node(new_node)
      existing_node.should be_nil
    end

    it "cannot delete a node that has relationships" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.delete_node(new_node1).should be_nil
      existing_node = @neo.get_node(new_node1)
      existing_node.should_not be_nil
    end

    it "returns nil if it tries to delete a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      @neo.delete_node(fake_node).should be_nil
      existing_node = @neo.get_node(fake_node)
      existing_node.should be_nil
    end

    it "returns nil if it tries to delete a node that has already been deleted" do
      new_node = @neo.create_node
      @neo.delete_node(new_node).should be_nil
      existing_node = @neo.get_node(new_node)
      existing_node.should be_nil
      @neo.delete_node(new_node).should be_nil
      existing_node = @neo.get_node(new_node)
      existing_node.should be_nil
    end
  end

  describe "delete_node!" do
    it "can delete an unrelated node" do
      new_node = @neo.create_node
      @neo.delete_node!(new_node).should be_nil
      existing_node = @neo.get_node(new_node)
      existing_node.should be_nil
    end

    it "can delete a node that has relationships" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.delete_node!(new_node1).should be_nil
      existing_node = @neo.get_node(new_node1)
      existing_node.should be_nil
    end

    it "returns nil if it tries to delete a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      @neo.delete_node!(fake_node).should be_nil
      existing_node = @neo.get_node(fake_node)
      existing_node.should be_nil
    end

    it "returns nil if it tries to delete a node that has already been deleted" do
      new_node = @neo.create_node
      @neo.delete_node!(new_node).should be_nil
      existing_node = @neo.get_node(new_node)
      existing_node.should be_nil
      @neo.delete_node!(new_node).should be_nil
      existing_node = @neo.get_node(new_node)
      existing_node.should be_nil
    end
  end

end
