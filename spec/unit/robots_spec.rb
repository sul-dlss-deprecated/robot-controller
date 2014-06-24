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
  
  context "parse_instances" do
    subject {
      RobotConfigParser.new
    }
    it "valid inputs" do
      expect(subject.parse_instances(0)).to eq 1
      expect(subject.parse_instances(1)).to eq 1
      expect(subject.parse_instances(16)).to eq 16
    end
    
    it "invalid inputs" do
      expect {
        subject.parse_instances(17)
      }.to raise_error RuntimeError
    end
  end
  
  context "parse_lanes" do
    subject {
      RobotConfigParser.new
    }
    
    it "valid inputs" do
      expect(subject.parse_lanes('*')).to eq ['*']
      expect(subject.parse_lanes('')).to eq ['default']
      expect(subject.parse_lanes('default')).to eq ['default']
      expect(subject.parse_lanes('A')).to eq ['A']
      expect(subject.parse_lanes('A,B')).to eq ['A', 'B']
    end
    
    it "tricky inputs" do
      expect(subject.parse_lanes(' ')).to eq ['default']
      expect(subject.parse_lanes(' , ')).to eq ['default']
      expect(subject.parse_lanes(' ,,')).to eq ['default']
      expect(subject.parse_lanes('A , B')).to eq ['A','B']
      expect(subject.parse_lanes('A-B')).to eq ['A-B']
      expect(subject.parse_lanes('A,B,A')).to eq ['A','B']
    end

  end
  
  context "build_queues" do
    subject {
      RobotConfigParser.new
    }
    
    it "valid inputs" do
      expect(subject.build_queues('z','*')).to eq ['z_*']
      expect(subject.build_queues('z','default')).to eq ['z_default']
      expect(subject.build_queues('z','A,B,C')).to eq ['z_A','z_B','z_C']
    end
    
  end
end