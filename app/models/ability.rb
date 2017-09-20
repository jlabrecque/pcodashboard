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
        can :manage, Person
        can :manage, CheckIn
        can :manage, Donation
        can :read, ActiveAdmin::Page, name: "Dashboard"
      end
      if user.pledge?
        can :manage, Pledge
        can :manage, Campaign
        can :read, ActiveAdmin::Page, name: "Dashboard"
        can :read, ActiveAdmin::Page, name: "Reports", namespace_name: :admin
      end

  end
end
