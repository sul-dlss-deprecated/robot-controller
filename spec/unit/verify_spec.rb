require 'robot-controller'

describe RobotController::Verify do
  context 'initialization' do
    subject do
      RobotController::Verify.new('robot1' => 1, 'robot2' => 2, 'robot3' => 0)
    end

    it 'has correct robots' do
      expect(subject.robots).to eq %w(robot1 robot2 robot3)
    end

    it 'has correct enabled' do
      expect(subject.running('robot1')).to eq 1
      expect(subject.running('robot2')).to eq 2
      expect(subject.running('robot3')).to eq 0
    end

    it 'handles empty parameters' do
      expect { RobotController::Verify.new }.to raise_error(ArgumentError)
    end
  end

  context 'parse_status methods' do
    subject do
      RobotController::Verify.new('dor_gisAssemblyWF_assign-placenames' => 1)
    end
    it 'parse single line' do
      expect(subject.class.parse_status_line('robot01_01_dor_gisAssemblyWF_assign-placenames(pid:29481): up')).to eq(
        nth: 1,
        pid: 29481,
        robot: 'dor_gisAssemblyWF_assign-placenames',
        state: :up
      )
      expect(subject.class.parse_status_line('robot01_02_dor_gisAssemblyWF_assign-placenames(pid:29482): starting')).to eq(
        nth: 2,
        pid: 29482,
        robot: 'dor_gisAssemblyWF_assign-placenames',
        state: :down
      )
    end

    it 'parses a single line with error' do
      expect(subject.class.parse_status_line('garbage')).to be_nil
    end

    it 'parse all lines' do
      expect(subject.class.parse_status_output([
        'robot01_01_dor_gisAssemblyWF_assign-placenames(pid:29481): starting',
        'robot01_02_dor_gisAssemblyWF_assign-placenames(pid:29482): unmonitored',
        'robot01_03_dor_gisAssemblyWF_assign-placenames(pid:29483): up'])).to eq(
          [
            {
              nth: 1,
              pid: 29481,
              robot: 'dor_gisAssemblyWF_assign-placenames',
              state: :down
            }, {
              nth: 2,
              pid: 29482,
              robot: 'dor_gisAssemblyWF_assign-placenames',
              state: :down
            }, {
              nth: 3,
              pid: 29483,
              robot: 'dor_gisAssemblyWF_assign-placenames',
              state: :up
            }
          ]
        )
    end
  end

  context 'verify method with single process' do
    subject do
      RobotController::Verify.new('dor_gisAssemblyWF_assign-placenames' => 1)
    end

    it 'runs controller status for up' do
      allow(subject).to receive(:controller_status).and_return([
        'robot01_01_dor_gisAssemblyWF_assign-placenames(pid:29483): up'
      ])
      expect(subject.verify).to eq(
        'dor_gisAssemblyWF_assign-placenames' => { state: :up, running: 1 }
      )
    end

    it 'runs controller status for down' do
      allow(subject).to receive(:controller_status).and_return([
        'robot01_01_dor_gisAssemblyWF_assign-placenames(pid:29481): down'
      ])
      expect(subject.verify).to eq(
        'dor_gisAssemblyWF_assign-placenames' => { state: :down, running: 0 }
      )
    end

    it 'runs controller status with errors' do
      allow(subject).to receive(:controller_status).and_return([
        'robot01_01_dor_gisAssemblyWF_assign-placenamesMISMATCH(pid:29481): down'
      ])
      expect(subject.robot_status('dor_gisAssemblyWF_assign-placenames')).to eq(
        state: :unknown, running: 0
      )
      # expect(subject.robot_status('dor_gisAssemblyWF_assign-placenamesMISMATCH')).to eq(
      #  { state: :not_enabled, running: 1 }
      # )
      expect { subject.robot_status('garbage') }.to raise_error(RuntimeError)
      expect(subject.verify).to eq(
        # 'dor_gisAssemblyWF_assign-placenamesMISMATCH' => { state: :not_enabled, running: 1 },
        'dor_gisAssemblyWF_assign-placenames' => { state: :unknown, running: 0 }
      )
    end

    it 'runs controller status even when broken' do
      allow(subject).to receive(:controller_status).and_return([])
      expect { subject.verify }.to raise_error(RuntimeError)
    end
  end

  context 'verify method with multiple processes' do
    subject do
      RobotController::Verify.new('dor_gisAssemblyWF_assign-placenames' => 3)
    end

    it 'runs controller status for up' do
      allow(subject).to receive(:controller_status).and_return([
        'robot01_01_dor_gisAssemblyWF_assign-placenames(pid:29483): up',
        'robot01_02_dor_gisAssemblyWF_assign-placenames(pid:29484): up',
        'robot02_01_dor_gisAssemblyWF_foobar(pid:29485): up',
        'robot01_02_dor_gisAssemblyWF_assign-placenames(pid:29486): up'
      ])
      expect(subject.verify).to eq(
        'dor_gisAssemblyWF_assign-placenames' => { state: :up, running: 3 }
      )
    end

    it 'runs controller status for down' do
      allow(subject).to receive(:controller_status).and_return([
        'robot01_01_dor_gisAssemblyWF_assign-placenames(pid:29481): starting',
        'robot01_02_dor_gisAssemblyWF_assign-placenames(pid:29482): unmonitored',
        'robot01_03_dor_gisAssemblyWF_assign-placenames(pid:29483): up',
        'robot02_01_dor_gisAssemblyWF_foobar(pid:29484): up',
        'robot02_02_dor_gisAssemblyWF_foobar(pid:29485): down'
      ])
      expect(subject.verify).to eq(
        'dor_gisAssemblyWF_assign-placenames' => { state: :down, running: 1 }
      )
    end

    it 'runs controller status for running mismatch' do
      allow(subject).to receive(:controller_status).and_return([
        'robot01_01_dor_gisAssemblyWF_assign-placenames(pid:29483): up',
        'robot01_02_dor_gisAssemblyWF_assign-placenames(pid:29484): up',
        'robot02_01_dor_gisAssemblyWF_foobar(pid:29486): up'
      ])
      expect(subject.verify).to eq(
        'dor_gisAssemblyWF_assign-placenames' => { state: :down, running: 2 }
      )
    end
  end

  context 'verify method with multiple robot queues' do
    subject do
      RobotController::Verify.new('dor_gisAssemblyWF_assign-placenames' => 3)
    end

    it 'runs controller status for up' do
      allow(subject).to receive(:controller_status).and_return([
        'robot01_01_dor_gisAssemblyWF_assign-placenames(pid:29483): up',
        'robot02_01_dor_gisAssemblyWF_foobar(pid:29485): up',
        'robot03_01_dor_gisAssemblyWF_assign-placenames(pid:29484): up',
        'robot04_01_dor_gisAssemblyWF_assign-placenames(pid:29486): up'
      ])
      expect(subject.verify).to eq(
        'dor_gisAssemblyWF_assign-placenames' => { state: :up, running: 3 }
      )
    end
  end
end
