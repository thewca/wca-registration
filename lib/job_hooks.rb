# frozen_string_literal: true

class JobHooks
  attr_writer :after_processing

  def initialize
    @after_processing = []
  end

  def after_processing(&blk)
    @after_processing << blk
  end

  def run(hook)
    defined_hooks = self.instance_variable_get(:"@#{hook}")
    defined_hooks.each(&:call)
  end
end
