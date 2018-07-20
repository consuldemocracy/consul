class I18nContent < ActiveRecord::Base

  scope :by_key, -> (key){ where(key: key) }
  scope :begins_with_key, -> (key){ where("key LIKE ?", "#{key}?%") }

  validates :key, uniqueness: true

  translates :value, touch: true
  globalize_accessors locales: [:en, :es, :fr, :nl, :val, :pt_br]

end