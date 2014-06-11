class WorkDir

  def self.find base_dir
    return ROBOT_ROOT if defined? ROBOT_ROOT

    bot_root = base_dir
    base = Pathname.new base_dir
    base.ascend do |p|
      if p.parent.basename.to_s =~ /releases/
        bot_root = p
        break
      end
    end
    bot_root
  end

end
