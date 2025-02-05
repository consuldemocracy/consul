load Rails.root.join("app", "models", "abilities", "common.rb")

module Abilities
  class Common
    alias_method :consul_initialize, :initialize # create a copy of the original method

    def initialize(user)
      consul_initialize(user) # call the original method
      cannot :create, Comment # undo the permission added in the original method

      if user.level_two_or_three_verified?
        can :create, Comment
      end
    end
  end
end
