module Budgets
  class InvestmentsController < ApplicationController
    include FeatureFlags
    include CommentableActions
    include FlagActions
    include RandomSeed
    include ImageAttributes
    include DocumentAttributes
    include MapLocationAttributes
    include Translatable

    PER_PAGE = 10

    before_action :authenticate_user!, except: [:index, :show, :json_data]
    before_action :load_budget, except: :json_data

    authorize_resource :budget, except: :json_data
    load_and_authorize_resource :investment, through: :budget, class: "Budget::Investment",
                                except: :json_data

    before_action :load_ballot, only: [:index, :show]
    before_action :load_heading, only: [:index, :show]
    before_action :load_assigned_heading, only: [:index, :show]
    before_action :load_map, only: [:index, :show]
    before_action :set_random_seed, only: :index
    before_action :load_categories, only: :index
    before_action :set_default_investment_filter, only: :index
    before_action :set_view, only: :index
    before_action :load_content_blocks, only: :index

    skip_authorization_check only: :json_data

    feature_flag :budgets

    has_orders %w[most_voted newest oldest], only: :show
    has_orders ->(c) { c.instance_variable_get(:@budget).investments_orders }, only: :index
    has_filters ->(c) { c.instance_variable_get(:@budget).investments_filters }, only: [:index, :show, :suggest]

    invisible_captcha only: [:create, :update], honeypot: :subtitle, scope: :budget_investment

    helper_method :resource_model, :resource_name
    respond_to :html, :js

    def index
      @investments = investments.page(params[:page]).per(PER_PAGE).for_render

      @investment_ids = @investments.ids
      @investments_map_coordinates = MapLocation.where(investment: investments).map(&:json_data)

      @tag_cloud = tag_cloud
      @remote_translations = detect_remote_translations(@investments)
    end

    def new
    end

    def show
      @commentable = @investment
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      set_comment_flags(@comment_tree.comments)
      @investment_ids = [@investment.id]
      @remote_translations = detect_remote_translations([@investment], @comment_tree.comments)
    end

    def create
      @investment.author = current_user
      @investment.heading = @budget.headings.first if @budget.single_heading?

      if @investment.save
        Mailer.budget_investment_created(@investment).deliver_later
        redirect_to budget_investment_path(@budget, @investment),
                    notice: t("flash.actions.create.budget_investment")
      else
        render :new
      end
    end

    def update
      if @investment.update(investment_params)
        redirect_to budget_investment_path(@budget, @investment),
                    notice: t("flash.actions.update.budget_investment")
      else
        render "edit"
      end
    end

    def destroy
      @investment.destroy!
      redirect_to user_path(current_user, filter: "budget_investments"), notice: t("flash.actions.destroy.budget_investment")
    end

    def suggest
      @resource_path_method = :namespaced_budget_investment_path
      @resource_relation    = resource_model.where(budget: @budget).apply_filters_and_search(@budget, params, @current_filter)
      super
    end

    def json_data
      investment = Budget::Investment.find(params[:id])
      data = {
        investment_id: investment.id,
        investment_title: investment.title,
        budget_id: investment.budget.id
      }.to_json

      respond_to do |format|
        format.json { render json: data }
      end
    end

    private

      def resource_model
        Budget::Investment
      end

      def resource_name
        "budget_investment"
      end

      def investment_params
        attributes = [:heading_id, :tag_list, :organization_name, :location,
                      :terms_of_service, :related_sdg_list,
                      image_attributes: image_attributes,
                      documents_attributes: document_attributes,
                      map_location_attributes: map_location_attributes]
        params.require(:budget_investment).permit(attributes, translation_params(Budget::Investment))
      end

      def load_ballot
        query = Budget::Ballot.where(user: current_user, budget: @budget)
        @ballot = @budget.balloting? ? query.first_or_create! : query.first_or_initialize
      end

      def load_heading
        if params[:heading_id].present?
          @heading = @budget.headings.find_by_slug_or_id! params[:heading_id]
        elsif @budget.single_heading?
          @heading = @budget.headings.first
        end
      end

      def load_assigned_heading
        if @investment
          @assigned_heading = @ballot&.heading_for_group(@investment.heading.group)
        else
          @assigned_heading = @ballot&.heading_for_group(@heading&.group)
        end
      end

      def load_categories
        @categories = Tag.category.order(:name)
      end

      def load_content_blocks
        @heading_content_blocks = @heading.content_blocks.where(locale: I18n.locale) if @heading
      end

      def tag_cloud
        TagCloud.new(Budget::Investment, params[:search])
      end

      def load_budget
        @budget = Budget.find_by_slug_or_id! params[:budget_id]
      end

      def set_view
        @view = (params[:view] == "minimal") ? "minimal" : "default"
      end

      def investments_with_filters
        @budget.investments.apply_filters_and_search(@budget, params, @current_filter)
      end

      def investments
        if @current_order == "random"
          investments_with_filters.sort_by_random(session[:random_seed])
        else
          investments_with_filters.send("sort_by_#{@current_order}")
        end
      end

      def set_default_investment_filter
        if @budget&.finished?
          params[:filter] ||= "winners"
        elsif @budget&.publishing_prices_or_later?
          params[:filter] ||= "selected"
        end
      end

      def load_map
        @map_location = MapLocation.load_from_heading(@heading) if @heading.present?
      end
  end
end
