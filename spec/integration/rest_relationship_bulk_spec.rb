require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
    @node1 = @neo.create_node
    @node2 = @neo.create_node
  end

  describe "can create many relationships threaded" do
    it "is faster than non-threaded?", :slow => true do
      Benchmark.bm do |x|
        x.report("create 50 relationships          "){ @non_threaded50 = 50.times{ @neo.create_relationship(:a, @node1, @node2) } }
        x.report("create 50 relationships threaded "){ @threaded50     = @neo.create_relationships([[:a, @node1, @node2]] * 50) }
        x.report("create 100 relationships         "){ @non_threaded50 = 100.times{ @neo.create_relationship(:a, @node1, @node2) } }
        x.report("create 100 relationships threaded"){ @threaded100    = @neo.create_relationships([[:a, @node1, @node2]] * 100) }
      end
    end
  end

  describe "can create many relationships" do
    it "can create empty relationships of various types" do
      new_relationships = @neo.create_relationships([[:a, @node1, @node2], [:b, @node1, @node2]])
      new_relationships.should_not be_nil
      new_relationships.size.should == 2
      @neo.get_node_relationships(@node1, :outgoing).size.should == 2
      @neo.get_node_relationships(@node1, :outgoing, :a).size.should == 1
      @neo.get_node_relationships(@node1, :outgoing, :b).size.should == 1
    end

    it "can create empty relationships" do
      new_relationships = @neo.create_relationships([[:a, @node1, @node2]] * 2)
      new_relationships.should_not be_nil
      new_relationships.size.should == 2
    end

    it "can create relationships with one property" do
      new_relationships = @neo.create_relationships([[:a, @node1, @node2, {"name" => "Max"}], [:a, @node1, @node2, {"name" => "Alex"}]])
      new_relationships[0]["data"]["name"].should == "Max"
      new_relationships[1]["data"]["name"].should == "Alex"
    end

    it "can create relationships with one property that are different" do
      new_relationships = @neo.create_relationships([[:a, @node1, @node2, {"name" => "Max"}], [:a, @node1, @node2, {"age" => 24}]])
      new_relationships[0]["data"]["name"].should == "Max"
      new_relationships[1]["data"]["age"].should == 24
    end

    it "can create relationships with more than one property" do
      new_relationships = @neo.create_relationships([[:a, @node1, @node2, {"name" => "Max", "age" => 31}], [:a, @node1, @node2, {"name" => "Alex", "age" => 24}]])
      new_relationships[0]["data"]["name"].should == "Max"
      new_relationships[0]["data"]["age"].should == 31
      new_relationships[1]["data"]["name"].should == "Alex"
      new_relationships[1]["data"]["age"].should == 24
    end

    it "can create relationships with more than one property that are different" do
      new_relationships = @neo.create_relationships([[:a, @node1, @node2, {"name" => "Max", "age" => 31}], [:a, @node1, @node2, {"weight" => 215, "height" => "5-11"}]])
      new_relationships[0]["data"]["name"].should == "Max"
      new_relationships[0]["data"]["age"].should == 31
      new_relationships[1]["data"]["height"].should == "5-11"
      new_relationships[1]["data"]["weight"].should == 215
    end

    it "is not super slow?", :slow => true do
      Benchmark.bm do |x|
        x.report(  "create 1 relationship" ) { @neo.create_relationships([[:a, @node1, @node2]] *   1) }
        x.report( "create 10 relationships") { @neo.create_relationships([[:a, @node1, @node2]] *  10) }
        x.report("create 100 relationships") { @neo.create_relationships([[:a, @node1, @node2]] * 100) }
      end
    end
  end
end
