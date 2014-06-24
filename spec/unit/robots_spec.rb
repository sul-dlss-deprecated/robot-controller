require 'robot-controller/robots'

describe RobotConfigParser do
  
  context "simple" do
    subject {
      RobotConfigParser.new.load('standard.yml', 'spec/fixtures', 'host1')
    }

    it "pass1" do
     expect(subject).to eq [
        {:robot=>"X", :queues=>["X_default"], :n=>1},
        {:robot=>"Y", :queues=>["Y_B"], :n=>1},
        {:robot=>"Z", :queues=>["Z_C"], :n=>3}
      ]
    end    
  end
  
  context "expanded" do
    subject {
      RobotConfigParser.new.load('standard.yml', 'spec/fixtures', 'host2')
    }

    it "pass2" do
     expect(subject).to eq [
        {:robot=>"A", :queues=>["A_*"], :n=>1},
        {:robot=>"B", :queues=>["B_X", "B_Y"], :n=>1},
        {:robot=>"C", :queues=>["C_X", "C_Y", "C_Z"], :n=>5},
        {:robot=>"D", :queues=>["D_default"], :n=>1},
      ]
    end    
  end
end