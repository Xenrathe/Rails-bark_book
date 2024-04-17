class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :addresses, as: :addressable
  belongs_to :primary_address, class_name: 'Address', optional: true
  has_many :dogs, dependent: :destroy
  has_many :contents, dependent: :destroy
  has_many :play_dates, dependent: :destroy
  has_many :comments
  has_many :barks

  has_many :followings, dependent: :destroy
  has_many :followed_dogs, through: :followings, source: :dog

  has_many :dog_park_followings, dependent: :destroy
  has_many :followed_dog_parks, through: :dog_park_followings, source: :dog_park

  has_one_attached :custom_bark

  validates :email, :time_zone, presence: true
  validates :username, presence: true, uniqueness: true, length: { maximum: 25 }

  # Follow/track either dog or dog_park
  def follow(object)
    if object.class.name.downcase == 'dog'
      followed_dogs << object unless following?(object)
    elsif object.class.name.downcase == 'dogpark'
      followed_dog_parks << object unless following?(object)
    end
  end

  # Unfollow/track either dog or dog_park
  def unfollow(object)
    if object.class.name.downcase == 'dog'
      followed_dogs.delete(object)
    elsif object.class.name.downcase == 'dogpark'
      followed_dog_parks.delete(object)
    end
  end

  # Check if following either dog or dog_park
  def following?(object)
    followed_dogs.include?(object) || followed_dog_parks.include?(object)
  end

  # Omniauth stuff
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first

    unless user
      user = find_by(email: auth.info.email)

      if user
        user.update(provider: auth.provider, uid: auth.uid)
      else
        user = new(email: auth.info.email,
                   password: Devise.friendly_token[0, 20],
                   username: generate_unique_username(auth.info.name.parameterize),
                   provider: auth.provider,
                   uid: auth.uid)
        user.save
      end
    end
    
    user
    #username = auth.info.name.parameterize
    #username = generate_unique_username(username)
    #where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    #  user.email = auth.info.email
    #  user.password = Devise.friendly_token[0, 20]
    #  user.username = username
    #end
  end

  # Since username is unique, this simply adds an increasing number onto name until it's free
  def self.generate_unique_username(username)
    existing_user = User.find_by(username: username)
    if existing_user
      i = 1
      loop do
        new_username = "#{username}#{i}"
        puts "Testing username: #{new_username}"
        break unless User.find_by(username: new_username)
        i += 1
      end
      username = "#{username}#{i}"
    end
    username
  end
end
