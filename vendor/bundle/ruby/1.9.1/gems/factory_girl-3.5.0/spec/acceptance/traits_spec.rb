require "spec_helper"

describe "an instance generated by a factory with multiple traits" do
  before do
    define_model("User",
                 name:          :string,
                 admin:         :boolean,
                 gender:        :string,
                 email:         :string,
                 date_of_birth: :date,
                 great:         :string)

    FactoryGirl.define do
      factory :user_without_admin_scoping, class: User do
        admin_trait
      end

      factory :user do
        name "John"

        trait :great do
          great "GREAT!!!"
        end

        trait :admin do
          admin true
        end

        trait :admin_trait do
          admin true
        end

        trait :male do
          name   "Joe"
          gender "Male"
        end

        trait :female do
          name   "Jane"
          gender "Female"
        end

        factory :great_user do
          great
        end

        factory :admin, traits: [:admin]

        factory :male_user do
          male

          factory :child_male_user do
            date_of_birth { Date.parse("1/1/2000") }
          end
        end

        factory :female, traits: [:female] do
          trait :admin do
            admin true
            name "Judy"
          end

          factory :female_great_user do
            great
          end

          factory :female_admin_judy, traits: [:admin]
        end

        factory :female_admin,            traits: [:female, :admin]
        factory :female_after_male_admin, traits: [:male, :female, :admin]
        factory :male_after_female_admin, traits: [:female, :male, :admin]
      end

      trait :email do
        email { "#{name}@example.com" }
      end

      factory :user_with_email, class: User, traits: [:email] do
        name "Bill"
      end
    end
  end

  context "the parent class" do
    subject      { FactoryGirl.create(:user) }
    its(:name)   { should == "John" }
    its(:gender) { should be_nil }
    it           { should_not be_admin }
  end

  context "the child class with one trait" do
    subject      { FactoryGirl.create(:admin) }
    its(:name)   { should == "John" }
    its(:gender) { should be_nil }
    it           { should be_admin }
  end

  context "the other child class with one trait" do
    subject      { FactoryGirl.create(:female) }
    its(:name)   { should == "Jane" }
    its(:gender) { should == "Female" }
    it           { should_not be_admin }
  end

  context "the child with multiple traits" do
    subject      { FactoryGirl.create(:female_admin) }
    its(:name)   { should == "Jane" }
    its(:gender) { should == "Female" }
    it           { should be_admin }
  end

  context "the child with multiple traits and overridden attributes" do
    subject      { FactoryGirl.create(:female_admin, name: "Jill", gender: nil) }
    its(:name)   { should == "Jill" }
    its(:gender) { should be_nil }
    it           { should be_admin }
  end

  context "the child with multiple traits who override the same attribute" do
    context "when the male assigns name after female" do
      subject      { FactoryGirl.create(:male_after_female_admin) }
      its(:name)   { should == "Joe" }
      its(:gender) { should == "Male" }
      it           { should be_admin }
    end

    context "when the female assigns name after male" do
      subject      { FactoryGirl.create(:female_after_male_admin) }
      its(:name)   { should == "Jane" }
      its(:gender) { should == "Female" }
      it           { should be_admin }
    end
  end

  context "child class with scoped trait and inherited trait" do
    subject      { FactoryGirl.create(:female_admin_judy) }
    its(:name)   { should == "Judy" }
    its(:gender) { should == "Female" }
    it           { should be_admin }
  end

  context "factory using global trait" do
    subject     { FactoryGirl.create(:user_with_email) }
    its(:name)  { should == "Bill" }
    its(:email) { should == "Bill@example.com"}
  end

  context "factory created with alternate syntax for specifying trait" do
    subject      { FactoryGirl.create(:male_user) }
    its(:gender) { should == "Male" }
  end

  context "factory created with alternate syntax where trait name and attribute are the same" do
    subject     { FactoryGirl.create(:great_user) }
    its(:great) { should == "GREAT!!!" }
  end

  context "factory created with alternate syntax where trait name and attribute are the same and attribute is overridden" do
    subject     { FactoryGirl.create(:great_user, great: "SORT OF!!!") }
    its(:great) { should == "SORT OF!!!" }
  end

  context "child factory created where trait attributes are inherited" do
    subject             { FactoryGirl.create(:child_male_user) }
    its(:gender)        { should == "Male" }
    its(:date_of_birth) { should == Date.parse("1/1/2000") }
  end

  context "factory outside of scope" do
    subject     { FactoryGirl.create(:user_without_admin_scoping) }
    it { expect { subject }.to raise_error(ArgumentError, "Trait not registered: admin_trait") }
  end

  context "child factory using grandparents' trait" do
    subject     { FactoryGirl.create(:female_great_user) }
    its(:great) { should == "GREAT!!!" }
  end
end

describe "traits with callbacks" do
  before do
    define_model("User", name: :string)

    FactoryGirl.define do
      factory :user do
        name "John"

        trait :great do
          after(:create) {|user| user.name.upcase! }
        end

        trait :awesome do
          after(:create) {|user| user.name = "awesome" }
        end

        factory :caps_user, traits: [:great]
        factory :awesome_user, traits: [:great, :awesome]

        factory :caps_user_implicit_trait do
          great
        end
      end
    end
  end

  context "when the factory has a trait passed via arguments" do
    subject    { FactoryGirl.create(:caps_user) }
    its(:name) { should == "JOHN" }
  end

  context "when the factory has an implicit trait" do
    subject    { FactoryGirl.create(:caps_user_implicit_trait) }
    its(:name) { should == "JOHN" }
  end

  it "executes callbacks in the order assigned" do
    FactoryGirl.create(:awesome_user).name.should == "awesome"
  end
end

describe "traits added via strategy" do
  before do
    define_model("User", name: :string, admin: :boolean)

    FactoryGirl.define do
      factory :user do
        name "John"

        trait :admin do
          admin true
        end

        trait :great do
          after(:create) {|user| user.name.upcase! }
        end
      end
    end
  end

  context "adding traits in create" do
    subject { FactoryGirl.create(:user, :admin, :great, name: "Joe") }

    its(:admin) { should be_true }
    its(:name)  { should == "JOE" }

    it "doesn't modify the user factory" do
      subject
      FactoryGirl.create(:user).should_not be_admin
      FactoryGirl.create(:user).name.should == "John"
    end
  end

  context "adding traits in build" do
    subject { FactoryGirl.build(:user, :admin, :great, name: "Joe") }

    its(:admin) { should be_true }
    its(:name)  { should == "Joe" }
  end

  context "adding traits in attributes_for" do
    subject { FactoryGirl.attributes_for(:user, :admin, :great) }

    its([:admin]) { should be_true }
    its([:name])  { should == "John" }
  end

  context "adding traits in build_stubbed" do
    subject { FactoryGirl.build_stubbed(:user, :admin, :great, name: "Jack") }

    its(:admin) { should be_true }
    its(:name)  { should == "Jack" }
  end

  context "adding traits in create_list" do
    subject { FactoryGirl.create_list(:user, 2, :admin, :great, name: "Joe") }

    its(:length) { should == 2 }

    it "creates all the records" do
      subject.each do |record|
        record.admin.should be_true
        record.name.should == "JOE"
      end
    end
  end

  context "adding traits in build_list" do
    subject { FactoryGirl.build_list(:user, 2, :admin, :great, name: "Joe") }

    its(:length) { should == 2 }

    it "builds all the records" do
      subject.each do |record|
        record.admin.should be_true
        record.name.should == "Joe"
      end
    end
  end
end

describe "traits and dynamic attributes that are applied simultaneously" do
  before do
    define_model("User", name: :string, email: :string, combined: :string)

    FactoryGirl.define do
      trait :email do
        email { "#{name}@example.com" }
      end

      factory :user do
        name "John"
        email
        combined { "#{name} <#{email}>" }
      end
    end
  end

  subject        { FactoryGirl.build(:user) }
  its(:name)     { should == "John" }
  its(:email)    { should == "John@example.com" }
  its(:combined) { should == "John <John@example.com>" }
end

describe "applying inline traits" do
  before do
    define_model("User") do
      has_many :posts
    end

    define_model("Post", user_id: :integer) do
      belongs_to :user
    end

    FactoryGirl.define do
      factory :user do
        trait :with_post do
          posts { [ Post.new ] }
        end
      end
    end
  end

  it "applies traits only to the instance generated for that call" do
    FactoryGirl.create(:user, :with_post).posts.should_not be_empty
    FactoryGirl.create(:user).posts.should be_empty
    FactoryGirl.create(:user, :with_post).posts.should_not be_empty
  end
end

describe "inline traits overriding existing attributes" do
  before do
    define_model("User", status: :string)

    FactoryGirl.define do
      factory :user do
        status "pending"

        trait(:accepted) { status "accepted" }
        trait(:declined) { status "declined" }

        factory :declined_user, traits: [:declined]
        factory :extended_declined_user, traits: [:declined] do
          status "extended_declined"
        end
      end
    end
  end

  it "returns the default status" do
    FactoryGirl.build(:user).status.should == "pending"
  end

  it "prefers inline trait attributes over default attributes" do
    FactoryGirl.build(:user, :accepted).status.should == "accepted"
  end

  it "prefers traits on a factory over default attributes" do
    FactoryGirl.build(:declined_user).status.should == "declined"
  end

  it "prefers inline trait attributes over traits on a factory" do
    FactoryGirl.build(:declined_user, :accepted).status.should == "accepted"
  end

  it "prefers attributes on factories over attributes from non-inline traits" do
    FactoryGirl.build(:extended_declined_user).status.should == "extended_declined"
  end

  it "prefers inline traits over attributes on factories" do
    FactoryGirl.build(:extended_declined_user, :accepted).status.should == "accepted"
  end

  it "prefers overridden attributes over attributes from traits, inline traits, or attributes on factories" do
    FactoryGirl.build(:extended_declined_user, :accepted, status: "completely overridden").status.should == "completely overridden"
  end
end

describe "making sure the factory is properly compiled the first time we want to instantiate it" do
  before do
    define_model("User", role: :string, gender: :string, age: :integer)

    FactoryGirl.define do
      factory :user do
        trait(:female) { gender "female" }
        trait(:admin) { role "admin" }

        factory :female_user do
          female
        end
      end
    end
  end

  it "can honor traits on the very first call" do
    user = FactoryGirl.build(:female_user, :admin, age: 30)
    user.gender.should == 'female'
    user.age.should == 30
    user.role.should == 'admin'
  end
end

describe "traits with to_create" do
  before do
    define_model("User", name: :string)

    FactoryGirl.define do
      factory :user do
        trait :with_to_create do
          to_create {|instance| instance.name = "to_create" }
        end

        factory :sub_user do
          to_create {|instance| instance.name = "sub" }

          factory :child_user
        end

        factory :sub_user_with_trait do
          with_to_create

          factory :child_user_with_trait
        end

        factory :sub_user_with_trait_and_override do
          with_to_create
          to_create {|instance| instance.name = "sub with trait and override" }

          factory :child_user_with_trait_and_override
        end
      end
    end
  end

  it "can apply to_create from traits" do
    FactoryGirl.create(:user, :with_to_create).name.should == "to_create"
  end

  it "can apply to_create from the definition" do
    FactoryGirl.create(:sub_user).name.should == "sub"
    FactoryGirl.create(:child_user).name.should == "sub"
  end

  it "gives additional traits higher priority than to_create from the definition" do
    FactoryGirl.create(:sub_user, :with_to_create).name.should == "to_create"
    FactoryGirl.create(:child_user, :with_to_create).name.should == "to_create"
  end

  it "gives base traits normal priority" do
    FactoryGirl.create(:sub_user_with_trait).name.should == "to_create"
    FactoryGirl.create(:child_user_with_trait).name.should == "to_create"
  end

  it "gives base traits lower priority than overrides" do
    FactoryGirl.create(:sub_user_with_trait_and_override).name.should == "sub with trait and override"
    FactoryGirl.create(:child_user_with_trait_and_override).name.should == "sub with trait and override"
  end

  it "gives additional traits higher priority than base traits and factory definition" do
    FactoryGirl.define do
      trait :overridden do
        to_create {|instance| instance.name = "completely overridden" }
      end
    end

    FactoryGirl.create(:sub_user_with_trait_and_override, :overridden).name.should == "completely overridden"
    FactoryGirl.create(:child_user_with_trait_and_override, :overridden).name.should == "completely overridden"
  end
end

describe "traits with initialize_with" do
  before do
    ActiveSupport::Deprecation.silenced = true

    define_class("User") do
      attr_reader :name

      def initialize(name)
        @name = name
      end
    end

    FactoryGirl.define do
      factory :user do
        trait :with_initialize_with do
          initialize_with { new("initialize_with") }
        end

        factory :sub_user do
          initialize_with { new("sub") }

          factory :child_user
        end

        factory :sub_user_with_trait do
          with_initialize_with

          factory :child_user_with_trait
        end

        factory :sub_user_with_trait_and_override do
          with_initialize_with
          initialize_with { new("sub with trait and override") }

          factory :child_user_with_trait_and_override
        end
      end
    end
  end

  it "can apply initialize_with from traits" do
    FactoryGirl.build(:user, :with_initialize_with).name.should == "initialize_with"
  end

  it "can apply initialize_with from the definition" do
    FactoryGirl.build(:sub_user).name.should == "sub"
    FactoryGirl.build(:child_user).name.should == "sub"
  end

  it "gives additional traits higher priority than initialize_with from the definition" do
    FactoryGirl.build(:sub_user, :with_initialize_with).name.should == "initialize_with"
    FactoryGirl.build(:child_user, :with_initialize_with).name.should == "initialize_with"
  end

  it "gives base traits normal priority" do
    FactoryGirl.build(:sub_user_with_trait).name.should == "initialize_with"
    FactoryGirl.build(:child_user_with_trait).name.should == "initialize_with"
  end

  it "gives base traits lower priority than overrides" do
    FactoryGirl.build(:sub_user_with_trait_and_override).name.should == "sub with trait and override"
    FactoryGirl.build(:child_user_with_trait_and_override).name.should == "sub with trait and override"
  end

  it "gives additional traits higher priority than base traits and factory definition" do
    FactoryGirl.define do
      trait :overridden do
        initialize_with { new("completely overridden") }
      end
    end

    FactoryGirl.build(:sub_user_with_trait_and_override, :overridden).name.should == "completely overridden"
    FactoryGirl.build(:child_user_with_trait_and_override, :overridden).name.should == "completely overridden"
  end
end

describe "nested implicit traits" do
  before do
    define_class("User") do
      attr_accessor :gender, :role
      attr_reader :name

      def initialize(name)
        @name = name
      end
    end
  end

  shared_examples_for "assigning data from traits" do
    it "assigns the correct values" do
      user = FactoryGirl.create(:user, :female_admin)
      user.gender.should == "FEMALE"
      user.role.should == "ADMIN"
      user.name.should == "Jane Doe"
    end
  end

  context "defined outside the factory" do
    before do
      FactoryGirl.define do
        trait :female do
          gender "female"
          to_create {|instance| instance.gender = instance.gender.upcase }
        end

        trait :jane_doe do
          initialize_with { new("Jane Doe") }
        end

        trait :admin do
          role "admin"
          after(:build) {|instance| instance.role = instance.role.upcase }
        end

        trait :female_admin do
          female
          admin
          jane_doe
        end

        factory :user
      end
    end

    it_should_behave_like "assigning data from traits"
  end

  context "defined inside the factory" do
    before do
      FactoryGirl.define do
        factory :user do
          trait :female do
            gender "female"
            to_create {|instance| instance.gender = instance.gender.upcase }
          end

          trait :jane_doe do
            initialize_with { new("Jane Doe") }
          end

          trait :admin do
            role "admin"
            after(:build) {|instance| instance.role = instance.role.upcase }
          end

          trait :female_admin do
            female
            admin
            jane_doe
          end
        end
      end
    end

    it_should_behave_like "assigning data from traits"
  end
end

describe "implicit traits containing callbacks" do
  before do
    define_model("User", value: :integer)

    FactoryGirl.define do
      factory :user do
        value 0

        trait :trait_with_callback do
          after(:build) {|user| user.value += 1 }
        end

        factory :user_with_trait_with_callback do
          trait_with_callback
        end
      end
    end
  end

  it "only runs the callback once" do
    FactoryGirl.build(:user_with_trait_with_callback).value.should == 1
  end
end
