require 'robot-controller/parser'

describe RobotController::Parser do
  context 'simple' do
    subject do
      RobotController::Parser.load('standard.yml', 'spec/fixtures', 'host1')
    end

    it 'parses correctly' do
      expect(subject).to eq [
        { robot: 'X', queues: ['X_default'], n: 1 },
        { robot: 'Y', queues: ['Y_B'], n: 1 },
        { robot: 'Z', queues: ['Z_C'], n: 3 }
      ]
    end
  end

  context 'expanded' do
    subject do
      RobotController::Parser.load('standard.yml', 'spec/fixtures', 'host2')
    end

    it 'parses correctly' do
      expect(subject).to eq [
        { robot: 'A', queues: ['A_*'], n: 1 },
        { robot: 'B', queues: %w(B_X B_Y), n: 1 },
        { robot: 'C', queues: %w(C_X C_Y C_Z), n: 5 },
        { robot: 'D', queues: ['D_default'], n: 1 }
      ]
    end
  end

  context 'expanded mismatched host' do
    it 'reports error' do
      expect do
        RobotController::Parser.load('standard.yml', 'spec/fixtures', 'host3')
      end.to raise_error(RuntimeError)
    end
  end

  context 'matcher' do
    subject do
      RobotController::Parser.load('matcher.yml', 'spec/fixtures', 'host3')
    end

    it 'parses correctly' do
      expect(subject).to eq [
        { robot: 'M', queues: ['M_default'], n: 1 },
        { robot: 'N', queues: ['N_B'], n: 2 },
        { robot: 'O', queues: ['O_C'], n: 3 }
      ]
    end
  end

  context 'multi' do
    subject do
      RobotController::Parser.load('multi.yml', 'spec/fixtures', 'host1')
    end

    it 'parses correctly' do
      expect(subject).to eq [
        { robot: 'X', queues: %w(X_default), n: 1 },
        { robot: 'X', queues: %w(X_A X_B X_C), n: 1 },
        { robot: 'X', queues: %w(X_D), n: 3 }
      ]
    end
  end

  context 'file-not-found' do
    it 'reports error' do
      expect do
        RobotController::Parser.load('nofile.yml', 'spec/fixtures', 'host3')
      end.to raise_error(RuntimeError)
    end
  end

  context 'instances_valid?' do
    it 'valid inputs' do
      expect(described_class.instances_valid?(0)).to eq 1
      expect(described_class.instances_valid?(1)).to eq 1
      expect(described_class.instances_valid?(8)).to eq 8
      expect(described_class.instances_valid?(16)).to eq 16
    end

    it 'invalid inputs' do
      expect do
        described_class.instances_valid?(17)
      end.to raise_error RuntimeError
    end
  end

  context 'parse_lanes' do
    it 'handles valid inputs' do
      expect(described_class.parse_lanes('*')).to eq ['*']
      expect(described_class.parse_lanes('')).to eq ['default']
      expect(described_class.parse_lanes('default')).to eq ['default']
      expect(described_class.parse_lanes('A')).to eq ['A']
      expect(described_class.parse_lanes('A,B')).to eq %w(A B)
    end

    it 'handles tricky inputs' do
      expect(described_class.parse_lanes(' ')).to eq ['default']
      expect(described_class.parse_lanes(' , ')).to eq ['default']
      expect(described_class.parse_lanes(' ,,')).to eq ['default']
      expect(described_class.parse_lanes('A , B')).to eq %w(A B)
      expect(described_class.parse_lanes('A-B')).to eq ['A-B']
      expect(described_class.parse_lanes('A,B,A')).to eq %w(A B)
    end
  end

  context 'queue_names' do
    it 'handles valid inputs' do
      expect(described_class.queue_names('z', '*')).to eq ['z_*']
      expect(described_class.queue_names('z', 'default')).to eq ['z_default']
      expect(described_class.queue_names('z', 'A,B,C')).to eq %w(z_A z_B z_C)
    end
  end
end
