class Comment < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user
  belongs_to :commentable, polymorphic: true
  belongs_to :parent, optional: true, class_name: "Comment"

  validates :body, presence: true

  def comments
    Comment.where(commentable: commentable, parent_id: id)
  end

  after_create_commit do
    broadcast_prepend_to [commentable, :comments], target: "#{dom_id(commentable)}_comments", locals: { comment: self, current_user: self.user }
  end

  after_destroy_commit do
    broadcast_remove_to self
  end
end
