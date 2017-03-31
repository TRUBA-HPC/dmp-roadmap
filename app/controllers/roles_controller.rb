class RolesController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  def create
    @role = Role.new(role_params)
    authorize @role
    @role.access_level = params[:role][:access_level].to_i
    if params[:user].present?
      message = _('User added to project')
      user = User.find_by(email: params[:user])
      if user.nil?
        User.invite!(email: params[:user])
        message = _('Invitation issued successfully.')
        user = User.find_by(email: params[:user])
      end
      @role.user = user
      if @role.save
        UserMailer.sharing_notification(@role).deliver
        flash[:notice] = message
      else
        flash[:notice] = @role.errors
      end
    else
      flash[:notice] = _('Please enter an email address')
    end
    redirect_to controller: 'plans', action: 'share', id: @role.plan.id
  end


  def update
    @role = Role.find(params[:id])
    authorize @role
    @role.access_level = params[:role][:access_level].to_i
    if @role.update_attributes(role_params)
      flash[:notice] = _('Sharing details successfully updated.')
      UserMailer.permissions_change_notification(@role).deliver
      redirect_to controller: 'plans', action: 'share', id: @role.plan.id
    else
      render action: "edit"
    end
  end

  def destroy
    @role = Role.find(params[:id])
    authorize @role
    user = @role.user
    plan = @role.plan
    @role.destroy

    flash[:notice] = _('Access removed')
    UserMailer.project_access_removed_notification(user, plan).deliver
    redirect_to controller: 'plans', action: 'share', id: @role.plan.slug
  end

  private

  def role_params
    params.require(:role).permit(:plan_id, :access_level)
  end
end