class Micropost < ApplicationRecord
  MAX_THREAD_DEPTH = 3

  belongs_to :user
  belongs_to :parent, class_name: 'Micropost', optional: true, inverse_of: :replies
  has_many :replies, -> { order(created_at: :asc) }, class_name: 'Micropost', foreign_key: 'parent_id', dependent: :destroy, inverse_of: :parent

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end

  default_scope -> { order(created_at: :desc) }

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png],
                                    message: 'must be a valid image format' },
                    size: { less_than: 5.megabytes,
                            message: 'should be less than 5MB' }

  validate :parent_thread_depth_within_limit

  scope :root_posts, -> { where(parent_id: nil) }
  scope :thread, lambda { |root|
    root_id = root.respond_to?(:id) ? root.id : root
    where(parent_id: root_id).or(where(id: root_id))
  }
  scope :replies, -> { where.not(parent_id: nil) }

  def thread_depth
    parent ? parent.thread_depth + 1 : 1
  end

  private

  def parent_thread_depth_within_limit
    return unless parent

    errors.add(:parent, "thread depth must be #{MAX_THREAD_DEPTH} levels or less") if parent.thread_depth >= MAX_THREAD_DEPTH
  end
end
