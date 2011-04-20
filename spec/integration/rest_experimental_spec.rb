require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end


  describe "get_nodes", :slow => true do
    it "can get nodes that exists" do
      existing_nodes = @neo.get_nodes
      existing_nodes.should_not be_nil
    end

    it "can get all nodes that exists the ugly way" do
      new_node = @neo.create_node
      last_node_id = new_node["self"].split('/').last.to_i
      existing_nodes = @neo.get_nodes((1..last_node_id).to_a)
      existing_nodes.should_not be_nil
    end
  end
end
