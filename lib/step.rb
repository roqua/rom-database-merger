class Step
  attr_reader :source, :target

  def initialize(source, target)
    @source = source
    @target = target
  end
end
