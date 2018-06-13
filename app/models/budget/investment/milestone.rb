class Budget
  class Investment
    class Milestone < ActiveRecord::Base
      include Imageable
      include Documentable
      documentable Setting['max_documents_allowed'].to_i
                   Setting['max_file_size'].to_i.megabytes
                   Setting['accepted_content_types']
      translates :title, :description, touch: true
      globalize_accessors locales: [:en, :es, :fr, :nl, :val, :pt_br]

      belongs_to :investment

      validates :title, presence: true
      validates :description, presence: true
      validates :investment, presence: true
      validates :publication_date, presence: true

      scope :order_by_publication_date, -> { order(publication_date: :asc) }

      def self.title_max_length
        80
      end

    end
  end
end
