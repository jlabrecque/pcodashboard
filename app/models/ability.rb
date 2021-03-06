class Ability
  include CanCan::Ability
  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
      if user.admin?
        can :manage, :all
        # can :manage, Settings
      elsif user.core?
        can :manage, Person
        can :manage, CheckIn
        can :manage, Donation
        can :read, ActiveAdmin::Page, name: "Dashboard"
        can :manage, Hgift
        can :manage, Fund
        can :manage, Peoplelist
      elsif user.pledge?
        can :manage, Pledge
        can :manage, Campaign
        can :manage, PledgeReport
        can :read, ActiveAdmin::Page, name: "Dashboard"
        can :read, ActiveAdmin::Page, name: "Pledge Dashboard"
      end

  end
end
