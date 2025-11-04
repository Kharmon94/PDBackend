# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      # Admin can do everything
      can :manage, :all
      can :manage, :admin_panel
    elsif user.distribution?
      # Distribution partners can manage their network
      can :read, Business
      can :manage, Business # All businesses in their network
      can :read, User
      can :read, :statistics
      can :manage, :distribution
      can :manage, WhiteLabel, user_id: user.id
    elsif user.partner?
      # Partners can manage their own businesses
      can :read, Business
      can :create, Business
      can :manage, Business, user_id: user.id
      can :read, Analytic, business: { user_id: user.id }
      can :manage, SavedDeal, user_id: user.id
    else
      # Regular users can browse and save
      can :read, Business
      can :track_click, Business
      can :manage, SavedDeal, user_id: user.id
    end

    # Everyone (including guests) can read public business info
    can :read, Business
    can :track_click, Business
  end
end

