class ClosingController < ApplicationController
  unloadable

  def change
    # TODO to settings
    custom_field_id_sum = 5
    custom_field_id_payed = 6
    custom_field_id_counted = 7
    status_id_closed = 5

    closed_status = IssueStatus.find(status_id_closed)
    custom_field_counted = IssueCustomField.find(custom_field_id_counted)

    # TODO payto issue must belong to same project as others
    # TODO check rights before (see application_controller.find_issue)
    issues = Issue.where(id: params[:ids]).order("created_on DESC")
    projects = Issue.where(id: params[:ids]).group(:project_id).count
    raise "all issues must belong to one project" if projects.size() != 1
    project_id, count = projects.first

    # TODO check if payto issue have payed < counted
    payout_issue = Issue.find(params[:payto])
    payed = payout_issue.custom_field_value(custom_field_id_payed).to_i
    counted = payout_issue.custom_field_value(custom_field_id_counted).to_i

    total_sum = 0
    description = ""

    issues.each  do |issue|
       issue_sum = issue.custom_field_value(custom_field_id_sum).to_i

       # if we should count next
       if (counted + issue_sum <= payed) and (issue_sum > 0)
         issue.init_journal(User.current)
         issue.notes = t(:issue_payed_and_closed_by, :issue_id => payout_issue.id, :sum => issue_sum)
         issue.status = closed_status
         issue.save

         description += "##{issue.id} = #{issue_sum} \n"
         counted += issue_sum
         total_sum += issue_sum
       end
    end

    description += t(:money_total, :sum => total_sum) + "\n"

    # TODO issue.save may return false + issue.errors.full_messages
    payout_issue.init_journal(User.current)
    payout_issue.description += description
    payout_issue.custom_field_values = {custom_field_counted.id => counted}
    payout_issue.save

    flash[:notice] = t(:data_updated, :issue_id => payout_issue.id)
    redirect_to :controller => 'issues', :action => 'index', :project_id => project_id
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
