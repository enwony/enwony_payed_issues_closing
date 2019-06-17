class ClosingController < ApplicationController
  unloadable

  before_filter :find_project
  before_filter :authorize
  menu_item :payed_closing

  # show form to fill - project, payout issue N, sum
  def index
  end

  # apply changes
  # TODO check rights before (see application_controller.find_issue)
  def change
    # TODO issue.save may return false + issue.errors.full_messages
    # TODO to settings
    custom_field_id_sum = 5
    ready_to_pay_status_id = 7
    closed_status = IssueStatus.find(5)

    # parameters
    payout_issue = Issue.find(params[:payout_issue])
    sum = params[:sum].to_i

    description = ""
    total_sum = 0

    # loop issues to handle
    issues = Issue.where(['project_id = ? and status_id = ?', @project.id, ready_to_pay_status_id]).order("created_on DESC")
    issues.each  do |issue|
       issue_sum = issue.custom_field_value(custom_field_id_sum).to_i

       # if we count next
       if sum - issue_sum >= 0
         issue.init_journal(User.current)
         issue.notes = t(:issue_payed_and_closed_by, :issue_id => payout_issue.id, :sum => issue_sum)
         issue.status = closed_status
         issue.save

         description += "##{issue.id} = #{issue_sum} \n"
         sum -= issue_sum
         total_sum += issue_sum
       end
    end

    description += t(:money_total, :sum => total_sum)
    if sum > 0
      description += t(:money_left, :sum => sum)
    end

    payout_issue.init_journal(User.current)
    payout_issue.description += description
    payout_issue.save

    flash[:notice] = t(:data_updated, :issue_id => payout_issue.id)
    redirect_to :action => 'index', :project_id => @project.id
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

end
