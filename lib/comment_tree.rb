class CommentTree

  ROOT_COMMENTS_PER_PAGE = 10

  attr_accessor :root_comments, :comments, :commentable, :page, :order

  def initialize(commentable, page, order = 'confidence_score', valuations: false)
    @commentable = commentable
    @page = page
    @order = order
    @valuations = valuations
    @comments = root_comments + root_descendants
  end

  def root_comments
    comments = order ? base_comments.roots.send("sort_by_#{order}") : base_comments.roots
    comments.page(page).per(ROOT_COMMENTS_PER_PAGE).for_render
  end

  def base_comments
    if @valuations && commentable.respond_to?('valuations')
      commentable.valuations
    else
      commentable.comments
    end
  end

  def root_descendants
    root_comments.each_with_object([]) do |root, array|
      comments = Comment.descendants_of(root)
      comments = comments.send("sort_descendants_by_#{order}") if order
      array.concat(comments).for_render.to_a
      # array.concat(Comment.descendants_of(root).send("sort_descendants_by_#{order}").for_render.to_a)
    end
  end

  def ordered_children_of(parent)
    comments_by_parent_id[parent.id] || []
  end

  def comments_by_parent_id
    comments.each_with_object({}) do |comment, array|
      (array[comment.parent_id] ||= []) << comment
    end
  end

  def comment_authors
    comments.map(&:author)
  end
end
