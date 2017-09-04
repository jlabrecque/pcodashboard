class Ability
  include CanCan::Ability
  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
      if user.admin?
        can :manage, :all
        # can :manage, Settings
      end
      if user.core?
    #    can :manage, Pledge
    #    can :manage, Campaign
        can :read, ActiveAdmin::Page, name: "Dashboard"
      end
      if user.pledge?
        can :manage, Pledge
        can :manage, Campaign
        can :read, ActiveAdmin::Page, name: "Dashboard"
        can :read, ActiveAdmin::Page, name: "Reports", namespace_name: :admin
      end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end

=begin
def initialize(user)
  can :manage, Post
  can :read, User
  can :manage, User, id: user.id
  can :read, ActiveAdmin::Page, name: "Dashboard", namespace_name: :admin
end

=end
