class Ability
  include CanCan::Ability

  def initialize(current_user)
    # load abilities for user's role
    if current_user.present?
      abilities_for_every_user(current_user)
      send("abilities_for_role_#{current_user.role}", current_user)
    end
  end

  private

  def abilities_for_every_user(current_user)
    can :create, Conversation
    can [:read, :update, :reply], Conversation do |conversation|
      conversation.usera == current_user || conversation.userb == current_user
    end

    can :update, User, :id => current_user.id
  end

  def abilities_for_role_admin(current_user)
    can :manage, User
    can :read, Blog
  end

  def abilities_for_role_moderator(current_user)
    can :read, User do |user|
      user.is?(current_user) || user.is?(:admin) ||
        user.is?(:participant) &&
        user.study.moderator.is?(current_user)
    end
    # THIS does NOT handle destroying of not own spectators or participants
    can [:new_spectator, :create_spectator, :destroy_spectator, :new_participant, :create_participant, :destroy_participant], User

    can :read, Blog do |blog|
      blog.study.moderator.is?(current_user)
    end
  end

  def abilities_for_role_spectator(current_user)
    can :read, User do |user|
      user.is?(current_user) ||
        user.is?(:participant) &&
        current_user.study.participants.map(&:id).include?(user.id)
    end

    can :read, Blog do |blog|
      blog.study.id == current_user.study.id
    end
  end

  def abilities_for_role_participant(current_user)
    can :read, User do |user|
      user.is?(current_user) ||
        !user.is?(:spectator) &&
        current_user.group_id == user.group_id &&
        current_user.group.can_user_see_eachother == true &&
        current_user.group.participants.include?(current_user)
    end

    can :read, Blog, group_id: current_user.group_id
    cannot :read, Blog, group: { can_user_see_eachother: false }
  end
end
