class Admin::Stats::BudgetSupportingComponent < ApplicationComponent
  attr_reader :budget
  delegate :include_javascript_in_layout, to: :helpers

  def initialize(budget)
    @budget = budget
  end

  private

    def stats
      @stats ||= Budget::Stats.new(budget)
    end

    def headings_stats
      @headings_stats ||= stats.headings
    end

    def vote_count
      stats.total_supports
    end

    def user_count
      stats.total_participants_support_phase
    end

    def user_count_by_heading
      budget.headings.map do |heading|
        [heading, headings_stats[heading.id][:total_participants_support_phase]]
      end
    end
end
