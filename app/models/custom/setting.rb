module Abilities
  class Common
    include CanCan::Ability

    def initialize(user)
      # Copy 100 lines of code here
      # can :create, Comment # Comment or delete the original line

      if user.level_two_or_three_verified? # Add your code
        can :create, Comment
      end
    end
  end
end
