authorization do
  role :guest do
    has_permission_on :authorization_rules, :to => :read
    has_permission_on :startpage, :to => :index
  end

  role :registered_ghostuser do
    includes :guest

    has_permission_on :help, :to => [:read]
  end

  role :registered_user do
    includes :registered_ghostuser

    has_permission_on :conversations, :to => [:create]
    has_permission_on :conversations, :to => [:read, :update, :reply] do
      if_attribute :usera => is { user }
      if_attribute :userb => is { user }
    end
  end

  role :admin do
    includes :registered_user

    has_permission_on :users, :to => [:manage, :manage_participants, :manage_spectators, :deactivate, :reactivate, :profile]
    has_permission_on :studies, :to => [:manage, :assign, :activate]
    has_permission_on :groups, :to => [:show, :edit, :new, :create, :destroy, :update]
    has_permission_on :blogs, :to => [:show]

    has_permission_on :mailings, :to => [:show, :edit] do
      if_attribute :moderator => is { user }
    end

    has_permission_on :mailings, :to => [:new, :create] do
      if_permitted_to :manage, :study
      #if_attribute :study => { :moderator => is { user } }
    end
  end

  role :moderator do
    includes :registered_user

    has_permission_on :studies, :to => [:read, :create, :update, :activate] do
      if_attribute :moderator => is { user }
    end
    has_permission_on :studies, :to => :delete do
      if_attribute :moderator => is { user }, :activated => is { false }
    end
    has_permission_on :groups, :to => [:show, :edit, :new, :create, :destroy, :update] do
      if_permitted_to :show, :study # moderator can only see groups of studies he may see
    end

    has_permission_on :users, :to => [:profile]
    has_permission_on :users, :to => [:show, :manage_participants, :manage_spectators] do
      if_attribute :study => { :moderator => is { user } }
    end

    has_permission_on :blogs, :to => [:read] do
      if_attribute :study => { :moderator => is { user } }
    end

    has_permission_on :mailings, :to => [:show, :edit] do
      if_attribute :moderator => is { user }
    end

    has_permission_on :mailings, :to => [:new, :create] do
      if_permitted_to :manage, :study
      #if_attribute :study => { :moderator => is { user } }
    end
  end

  role :participant do
    includes :registered_user

    has_permission_on :users, :to => [:setup]
    has_permission_on :users, :to => [:show, :profile] do
      if_attribute :group => { :participants => contains { user }, :can_user_see_eachother => is { true } }, :role => is_not { 'spectator' }
    end
    has_permission_on :blogs, :to => [:show, :add_image] do
      if_attribute :user => is { user }
    end
    has_permission_on :blog_entries, :to => [:new, :create] do
      if_attribute :blog => { :user => is { user } }
    end

    has_permission_on :startpage, :to => :ended
  end

  role :spectator do
    includes :registered_ghostuser

    has_permission_on :startpage, :to => :ended
    has_permission_on :users, :to => [:show] do
      if_attribute :study => { :participants => contains { user } }
    end
  end
end

privileges do
  # default privilege hierarchies to facilitate RESTful Rails apps
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read,   :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy

  privilege :manage_participants, :includes => [:new_participant, :create_participant, :destroy_participant]
  privilege :manage_spectators, :includes => [:new_spectator, :create_spectator, :destroy_spectator]
end
