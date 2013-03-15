class Ability
  include CanCan::Ability

  def initialize(user)
    # load abilities for user's role
    if user.present?
      abilities_for_every_user(user)
      send("abilities_for_role_#{user.role}", user)
    end
  end

  private

  def abilities_for_every_user(user)
    can :create, Conversation
    can [:read, :update, :reply], Conversation do |conversation|
      conversation.usera == user || conversation.userb == user
    end
  end

  def abilities_for_role_admin(user)
  end

  def abilities_for_role_moderator(user)
  end

  def abilities_for_role_spectator(user)
  end

  def abilities_for_role_participant(user)
  end
end
